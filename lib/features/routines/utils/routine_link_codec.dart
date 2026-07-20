import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../models/interval.dart';
import '../models/machine_type.dart';
import '../models/routine.dart';

/// Compact, self-contained routine links that need no server or storage.
class RoutineLinkCodec {
  static const String prefix = 'v:';
  static const int _version = 1;
  static const int _compressedMarker = 0x80;

  static const List<String> _defaultNames = [
    'Unnamed Routine',
    'Rutina Sin Nombre',
    'Routine Sans Nom',
    'Unbenannte Routine',
    'Routine senza nome',
    'Naamloze routine',
    'Unavngiven rutine',
    'Rutine uten navn',
    'Программа без названия',
    'Rotina Sem Nome',
    '名前のないルーティン',
    '未命名训练计划',
    '이름 없는 루틴',
    'Chương trình chưa đặt tên',
    'روتين بدون اسم',
    'รูทีนไม่มีชื่อ',
  ];

  static String encode(Routine routine) {
    final raw = _encodeRoutine(routine);
    final compressed = <int>[
      _compressedMarker,
      ...ZLibCodec(raw: true).encode(raw),
    ];
    final payload = compressed.length < raw.length ? compressed : raw;
    return '$prefix${base64Url.encode(payload).replaceAll('=', '')}';
  }

  static Routine? decode(String link) {
    if (!link.startsWith(prefix)) return null;
    try {
      final encoded = link.substring(prefix.length);
      if (encoded.isEmpty) return null;
      var bytes = base64Url.decode(base64Url.normalize(encoded));
      if (bytes.isEmpty) return null;
      if (bytes.first == _compressedMarker) {
        bytes = Uint8List.fromList(
          ZLibCodec(raw: true).decode(bytes.sublist(1)),
        );
      }
      return _decodeRoutine(Uint8List.fromList(bytes));
    } catch (_) {
      return null;
    }
  }

  static Uint8List _encodeRoutine(Routine routine) {
    final writer = _ByteWriter();
    final difficultyCode = _difficultyCode(routine.difficulty);
    final machineCode = switch (routine.machineType) {
      MachineType.treadmill => 0,
      MachineType.cycle => 1,
      MachineType.stairmaster => 2,
    };
    writer.byte((_version << 4) | (difficultyCode << 2) | machineCode);

    final defaultNameIndex = _defaultNames.indexOf(routine.name);
    if (defaultNameIndex >= 0) {
      writer.varUint(defaultNameIndex);
    } else {
      final nameBytes = utf8.encode(routine.name);
      writer.varUint(_defaultNames.length + nameBytes.length);
      writer.bytes(nameBytes);
    }
    if (difficultyCode == 3) writer.utf8String(routine.difficulty);

    writer.varUint(routine.intervals.length);
    final groupIndexes = <String, int>{};
    for (final interval in routine.intervals) {
      final hasRepeat =
          interval.groupId != null || interval.repeatCount != null;
      writer.varUint((interval.durationSeconds << 1) | (hasRepeat ? 1 : 0));
      switch (routine.machineType) {
        case MachineType.treadmill:
          writer.varUint(((interval.speedKmh ?? 0) * 10).round());
          writer.varInt(((interval.grade ?? 0) * 10).round());
        case MachineType.cycle:
          writer.varUint(interval.rpm ?? 0);
          writer.varUint(interval.resistance ?? 0);
        case MachineType.stairmaster:
          writer.varUint(interval.level ?? 0);
      }
      if (hasRepeat) {
        final groupId = interval.groupId;
        final groupIndex = groupId == null
            ? 0
            : groupIndexes.putIfAbsent(groupId, () => groupIndexes.length) + 1;
        writer.varUint(groupIndex);
        writer.varUint((interval.repeatCount ?? -1) + 1);
      }
    }
    return writer.result;
  }

  static Routine _decodeRoutine(Uint8List bytes) {
    final reader = _ByteReader(bytes);
    final header = reader.byte();
    if ((header >> 4) != _version) {
      throw const FormatException('Unsupported routine link version');
    }
    final machineType = switch (header & 0x03) {
      0 => MachineType.treadmill,
      1 => MachineType.cycle,
      2 => MachineType.stairmaster,
      _ => throw const FormatException('Invalid machine type'),
    };
    final difficultyCode = (header >> 2) & 0x03;

    final nameDescriptor = reader.varUint(max: 416);
    final name = nameDescriptor < _defaultNames.length
        ? _defaultNames[nameDescriptor]
        : reader.utf8String(nameDescriptor - _defaultNames.length);
    final difficulty = difficultyCode == 3
        ? reader.lengthPrefixedUtf8(maxLength: 400)
        : _difficultyFromCode(difficultyCode);

    final intervalCount = reader.varUint(max: 1000);
    final intervals = <Interval>[];
    for (var index = 0; index < intervalCount; index++) {
      final durationAndFlags = reader.varUint(max: 20000001);
      final durationSeconds = durationAndFlags >> 1;
      if (durationSeconds <= 0) {
        throw const FormatException('Invalid interval duration');
      }
      final hasRepeat = durationAndFlags.isOdd;

      double? speedKmh;
      double? grade;
      int? rpm;
      int? resistance;
      int? level;
      switch (machineType) {
        case MachineType.treadmill:
          speedKmh = reader.varUint(max: 10000) / 10;
          grade = reader.varInt(maxAbsolute: 10000) / 10;
        case MachineType.cycle:
          rpm = reader.varUint(max: 10000);
          resistance = reader.varUint(max: 10000);
        case MachineType.stairmaster:
          level = reader.varUint(max: 10000);
      }

      String? groupId;
      int? repeatCount;
      if (hasRepeat) {
        final groupIndex = reader.varUint(max: 1000);
        final encodedRepeatCount = reader.varUint(max: 10000);
        if (groupIndex > 0) groupId = 'imported_group_$groupIndex';
        if (encodedRepeatCount > 0) repeatCount = encodedRepeatCount - 1;
      }
      intervals.add(Interval(
        id: 'imported_interval_${DateTime.now().microsecondsSinceEpoch}_$index',
        durationSeconds: durationSeconds,
        speedKmh: speedKmh,
        grade: grade,
        rpm: rpm,
        resistance: resistance,
        level: level,
        groupId: groupId,
        repeatCount: repeatCount,
      ));
    }
    if (!reader.isAtEnd) throw const FormatException('Trailing link data');

    return Routine(
      id: 'imported_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      difficulty: difficulty,
      machineType: machineType,
      intervals: intervals,
    );
  }

  static int _difficultyCode(String difficulty) => switch (difficulty) {
        '쉬움' || 'beginner' => 0,
        '중간' || 'intermediate' => 1,
        '높음' || 'advanced' => 2,
        _ => 3,
      };

  static String _difficultyFromCode(int code) => switch (code) {
        0 => '쉬움',
        1 => '중간',
        2 => '높음',
        _ => throw const FormatException('Invalid difficulty'),
      };
}

class _ByteWriter {
  final BytesBuilder _builder = BytesBuilder(copy: false);

  void byte(int value) => _builder.addByte(value);
  void bytes(List<int> values) => _builder.add(values);

  void varUint(int value) {
    if (value < 0) throw ArgumentError.value(value, 'value');
    do {
      var next = value & 0x7f;
      value >>= 7;
      if (value != 0) next |= 0x80;
      byte(next);
    } while (value != 0);
  }

  void varInt(int value) {
    varUint(value >= 0 ? value * 2 : (-value * 2) - 1);
  }

  void utf8String(String value) {
    final encoded = utf8.encode(value);
    varUint(encoded.length);
    bytes(encoded);
  }

  Uint8List get result => _builder.toBytes();
}

class _ByteReader {
  _ByteReader(this._bytes);

  final Uint8List _bytes;
  int _offset = 0;

  bool get isAtEnd => _offset == _bytes.length;

  int byte() {
    if (_offset >= _bytes.length) throw const FormatException('Truncated link');
    return _bytes[_offset++];
  }

  int varUint({int max = 0x7fffffff}) {
    var value = 0;
    var shift = 0;
    while (shift <= 28) {
      final next = byte();
      value |= (next & 0x7f) << shift;
      if ((next & 0x80) == 0) {
        if (value > max) throw const FormatException('Value out of range');
        return value;
      }
      shift += 7;
    }
    throw const FormatException('Invalid variable integer');
  }

  int varInt({int maxAbsolute = 0x3fffffff}) {
    final encoded = varUint(max: maxAbsolute * 2 + 1);
    return encoded.isEven ? encoded ~/ 2 : -((encoded + 1) ~/ 2);
  }

  String lengthPrefixedUtf8({required int maxLength}) {
    return utf8String(varUint(max: maxLength));
  }

  String utf8String(int length) {
    if (length < 0 || _offset + length > _bytes.length) {
      throw const FormatException('Invalid string length');
    }
    final value = utf8.decode(_bytes.sublist(_offset, _offset + length));
    _offset += length;
    return value;
  }
}
