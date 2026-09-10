import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import { readFileSync } from 'fs';
import { resolve } from 'path';
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import {
  doc,
  getDoc,
  setDoc,
  deleteDoc,
  collection,
  getDocs,
} from 'firebase/firestore';

/**
 * These rules are the only thing standing between one person's workout
 * history and everyone else's, so they are exercised against the real
 * emulator rather than reasoned about.
 */
let testEnv: RulesTestEnvironment;

const OWNER = 'user-owner';
const OTHER = 'user-other';

/** A signed-in account, the only kind allowed to hold a backup. */
function account(uid: string) {
  return testEnv.authenticatedContext(uid, {
    firebase: { sign_in_provider: 'google.com' },
  }).firestore();
}

/** A guest. Has a uid, but nothing to come back to. */
function guest(uid: string) {
  return testEnv.authenticatedContext(uid, {
    firebase: { sign_in_provider: 'anonymous' },
  }).firestore();
}

const workout = {
  id: 'w1',
  machineType: 'treadmill',
  dateTime: '2026-05-01T07:30:00.000',
  durationSeconds: 1800,
  routineName: 'Intervals',
  routineId: 'r1',
};

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'valcue-rules-test',
    firestore: {
      host: '127.0.0.1',
      port: 8080,
      rules: readFileSync(resolve(__dirname, '../../firestore.rules'), 'utf8'),
    },
  });
});

afterAll(async () => {
  await testEnv?.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

describe('a signed-in account and its own backup', () => {
  it('can write and read back its own workout', async () => {
    const db = account(OWNER);
    const ref = doc(db, `users/${OWNER}/workouts/w1`);

    await assertSucceeds(setDoc(ref, workout));
    await assertSucceeds(getDoc(ref));
  });

  it('can write weights and routines too', async () => {
    const db = account(OWNER);

    await assertSucceeds(
      setDoc(doc(db, `users/${OWNER}/weights/e1`), {
        id: 'e1',
        dateTime: '2026-05-01T07:00:00.000',
        weightKg: 70,
      }),
    );
    await assertSucceeds(
      setDoc(doc(db, `users/${OWNER}/routines/r1`), {
        id: 'r1',
        name: 'Intervals',
        machineType: 'treadmill',
        intervals: [],
      }),
    );
  });

  it('can delete its own records', async () => {
    const db = account(OWNER);
    const ref = doc(db, `users/${OWNER}/workouts/w1`);
    await assertSucceeds(setDoc(ref, workout));

    await assertSucceeds(deleteDoc(ref));
  });
});

describe('someone else\'s backup', () => {
  beforeEach(async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(
        doc(context.firestore(), `users/${OWNER}/workouts/w1`),
        workout,
      );
    });
  });

  it('cannot be read', async () => {
    const db = account(OTHER);

    await assertFails(getDoc(doc(db, `users/${OWNER}/workouts/w1`)));
  });

  it('cannot be listed', async () => {
    const db = account(OTHER);

    await assertFails(getDocs(collection(db, `users/${OWNER}/workouts`)));
  });

  it('cannot be written to', async () => {
    const db = account(OTHER);

    await assertFails(
      setDoc(doc(db, `users/${OWNER}/workouts/w2`), workout),
    );
  });

  it('cannot be deleted', async () => {
    const db = account(OTHER);

    await assertFails(deleteDoc(doc(db, `users/${OWNER}/workouts/w1`)));
  });
});

describe('guests', () => {
  // The rules deliberately do not single out anonymous tokens - see the
  // comment in firestore.rules. What still has to hold is that a guest can
  // never reach anyone else's backup.
  it('cannot touch someone else\'s backup', async () => {
    const db = guest(OTHER);

    await assertFails(getDoc(doc(db, `users/${OWNER}/workouts/w1`)));
    await assertFails(
      setDoc(doc(db, `users/${OWNER}/workouts/w1`), workout),
    );
  });
});

describe('an account can clear itself out', () => {
  it('can delete its own root document', async () => {
    // Account deletion ends with this. An earlier draft required a size
    // check on every write, which a delete can never satisfy, so deleting
    // an account was impossible - and Apple requires it to be possible.
    const db = account(OWNER);

    await assertSucceeds(deleteDoc(doc(db, `users/${OWNER}`)));
  });

  it('can delete its own records', async () => {
    const db = account(OWNER);
    await assertSucceeds(
      setDoc(doc(db, `users/${OWNER}/weights/e1`), {
        id: 'e1',
        dateTime: '2026-05-01T07:00:00.000',
        weightKg: 70,
      }),
    );

    await assertSucceeds(deleteDoc(doc(db, `users/${OWNER}/weights/e1`)));
  });
});

describe('signed-out clients', () => {
  it('cannot read anything', async () => {
    const db = testEnv.unauthenticatedContext().firestore();

    await assertFails(getDoc(doc(db, `users/${OWNER}/workouts/w1`)));
  });

  it('cannot write anything', async () => {
    const db = testEnv.unauthenticatedContext().firestore();

    await assertFails(
      setDoc(doc(db, `users/${OWNER}/workouts/w1`), workout),
    );
  });
});

describe('everything outside a backup stays closed', () => {
  it('Live Activity session tokens are unreachable', async () => {
    const db = account(OWNER);

    await assertFails(getDoc(doc(db, 'liveActivitySessions/s1')));
    await assertFails(setDoc(doc(db, 'liveActivitySessions/s1'), { a: 1 }));
  });

  it('an unknown collection is unreachable', async () => {
    const db = account(OWNER);

    await assertFails(setDoc(doc(db, 'anythingElse/x'), { a: 1 }));
  });
});

describe('oversized documents', () => {
  it('are refused', async () => {
    const db = account(OWNER);
    const tooManyFields: Record<string, number> = {};
    for (let i = 0; i < 60; i++) tooManyFields[`f${i}`] = i;

    await assertFails(
      setDoc(doc(db, `users/${OWNER}/workouts/w1`), tooManyFields),
    );
  });

  it('a normal document is not caught by the size guard', async () => {
    const db = account(OWNER);

    await assertSucceeds(
      setDoc(doc(db, `users/${OWNER}/workouts/w1`), workout),
    );
    expect(Object.keys(workout).length).toBeLessThan(40);
  });
});
