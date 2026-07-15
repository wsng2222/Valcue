import 'package:flutter/material.dart';

import 'widgets/onboarding_emphasis_text.dart';

/// Onboarding-local strings for all supported app languages.
///
/// This avoids relying on gen-l10n for onboarding while still being fully
/// translatable and runtime-locale aware. Falls back to English.
class OnboardingStrings {
  final String code;

  const OnboardingStrings._(this.code);

  static OnboardingStrings of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return OnboardingStrings._(_supported.contains(code) ? code : 'en');
  }

  static const _supported = <String>{
    'en',
    'es',
    'fr',
    'de',
    'it',
    'nl',
    'da',
    'nb',
    'ru',
    'pt',
    'ja',
    'zh',
    'ko',
    'vi',
    'ar',
    'th',
  };

  // ---- CTA ----
  String ctaStart() => _t({
        'ko': '시작해볼까요',
        'en': "Let's start",
        'es': 'Empecemos',
        'fr': "C’est parti",
        'de': 'Los geht’s',
        'it': 'Iniziamo',
        'nl': 'Laten we beginnen',
        'da': 'Lad os starte',
        'nb': 'La oss starte',
        'ru': 'Начнём',
        'pt': 'Vamos começar',
        'ja': 'はじめましょう',
        'zh': '开始吧',
        'vi': 'Bắt đầu thôi',
        'ar': 'لنبدأ',
        'th': 'เริ่มกันเลย',
      });

  String ctaNext() => _t({
        'ko': '다음',
        'en': 'Next',
        'es': 'Siguiente',
        'fr': 'Suivant',
        'de': 'Weiter',
        'it': 'Avanti',
        'nl': 'Volgende',
        'da': 'Næste',
        'nb': 'Neste',
        'ru': 'Далее',
        'pt': 'Próximo',
        'ja': '次へ',
        'zh': '下一步',
        'vi': 'Tiếp theo',
        'ar': 'التالي',
        'th': 'ถัดไป',
      });

  String ctaFinish() => _t({
        'ko': '지금 시작하기',
        'en': 'Start now',
        'es': 'Empezar ahora',
        'fr': 'Commencer',
        'de': 'Jetzt starten',
        'it': 'Inizia ora',
        'nl': 'Nu starten',
        'da': 'Start nu',
        'nb': 'Start nå',
        'ru': 'Начать',
        'pt': 'Começar agora',
        'ja': '今すぐ始める',
        'zh': '立即开始',
        'vi': 'Bắt đầu ngay',
        'ar': 'ابدأ الآن',
        'th': 'เริ่มเลย',
      });

  // ---- Screen 1 ----
  String s1Title() => _t({
        'ko': '환영합니다!',
        'en': 'Welcome!',
        'es': '¡Bienvenido!',
        'fr': 'Bienvenue !',
        'de': 'Willkommen!',
        'it': 'Benvenuto!',
        'nl': 'Welkom!',
        'da': 'Velkommen!',
        'nb': 'Velkommen!',
        'ru': 'Добро пожаловать!',
        'pt': 'Bem-vindo!',
        'ja': 'ようこそ！',
        'zh': '欢迎！',
        'vi': 'Chào mừng!',
        'ar': 'مرحبًا!',
        'th': 'ยินดีต้อนรับ!',
      });

  String s1Subtitle() => _t({
        'ko': '이제 진정한 유산소의 세계에\n발을 들일 시간입니다',
        'en': "It's time to step into\nreal cardio.",
        'es': 'Es hora de entrar\nen el mundo del cardio real.',
        'fr': "Il est temps d’entrer\ndans le vrai cardio.",
        'de': 'Zeit, in die Welt\ndes echten Cardios einzutauchen.',
        'it': 'È il momento di entrare\nnel vero cardio.',
        'nl': 'Tijd om de wereld\nvan echte cardio binnen te stappen.',
        'da': 'Det er tid til at træde ind\ni ægte cardio.',
        'nb': 'Det er på tide å gå inn\ni ekte cardio.',
        'ru': 'Пора войти\nв мир настоящего кардио.',
        'pt': 'Está na hora de entrar\nno cardio de verdade.',
        'ja': '本物の有酸素の世界へ\n踏み出す時間です',
        'zh': '是时候迈入\n真正的有氧世界了',
        'vi': 'Đã đến lúc bước vào\nthế giới cardio thực sự.',
        'ar': 'حان الوقت للدخول\nإلى عالم الكارديو الحقيقي.',
        'th': 'ถึงเวลาเข้าสู่\nโลกของคาร์ดิโออย่างแท้จริงแล้ว',
      });

  // ---- Screen 2 ----
  List<EmphasisTextSpan> s2TitleSpans() => _spans({
        'ko': const [
          EmphasisTextSpan('몇분 걷고 몇분 뛰고 ...\n'),
          EmphasisTextSpan('인터벌 운동을 '),
          EmphasisTextSpan('직접 기획하세요!', isRed: true),
        ],
        'en': const [
          EmphasisTextSpan('Walk, run...\n'),
          EmphasisTextSpan('Plan your interval routine '),
          EmphasisTextSpan('yourself!', isRed: true),
        ],
        'es': const [
          EmphasisTextSpan('Camina, corre...\n'),
          EmphasisTextSpan('Planifica tu rutina de intervalos '),
          EmphasisTextSpan('tú mismo!', isRed: true),
        ],
        'fr': const [
          EmphasisTextSpan('Marche, cours...\n'),
          EmphasisTextSpan('Planifie ton entraînement '),
          EmphasisTextSpan('toi-même !', isRed: true),
        ],
        'de': const [
          EmphasisTextSpan('Gehen, laufen...\n'),
          EmphasisTextSpan('Plane dein Intervalltraining '),
          EmphasisTextSpan('selbst!', isRed: true),
        ],
        'it': const [
          EmphasisTextSpan('Cammina, corri...\n'),
          EmphasisTextSpan('Pianifica la tua routine a intervalli '),
          EmphasisTextSpan('da solo!', isRed: true),
        ],
        'nl': const [
          EmphasisTextSpan('Wandelen, rennen...\n'),
          EmphasisTextSpan('Plan je intervaltraining '),
          EmphasisTextSpan('zelf!', isRed: true),
        ],
        'da': const [
          EmphasisTextSpan('Gå, løb...\n'),
          EmphasisTextSpan('Planlæg din intervaltræning '),
          EmphasisTextSpan('selv!', isRed: true),
        ],
        'nb': const [
          EmphasisTextSpan('Gå, løp...\n'),
          EmphasisTextSpan('Planlegg intervalløkten '),
          EmphasisTextSpan('selv!', isRed: true),
        ],
        'ru': const [
          EmphasisTextSpan('Ходьба, бег...\n'),
          EmphasisTextSpan('Планируй интервальную тренировку '),
          EmphasisTextSpan('сам!', isRed: true),
        ],
        'pt': const [
          EmphasisTextSpan('Caminhe, corra...\n'),
          EmphasisTextSpan('Planeje seu treino intervalado '),
          EmphasisTextSpan('você mesmo!', isRed: true),
        ],
        'ja': const [
          EmphasisTextSpan('歩いて、走って…\n'),
          EmphasisTextSpan('インターバルを '),
          EmphasisTextSpan('自分で設計！', isRed: true),
        ],
        'zh': const [
          EmphasisTextSpan('走走、跑跑…\n'),
          EmphasisTextSpan('把间歇训练 '),
          EmphasisTextSpan('亲自规划！', isRed: true),
        ],
        'vi': const [
          EmphasisTextSpan('Đi bộ, chạy...\n'),
          EmphasisTextSpan('Tự lên kế hoạch bài interval '),
          EmphasisTextSpan('của bạn!', isRed: true),
        ],
        'ar': const [
          EmphasisTextSpan('امشِ، اركض…\n'),
          EmphasisTextSpan('خطّط لتمرينك المتقطع '),
          EmphasisTextSpan('بنفسك!', isRed: true),
        ],
        'th': const [
          EmphasisTextSpan('เดิน วิ่ง…\n'),
          EmphasisTextSpan('วางแผนอินเทอร์วัล '),
          EmphasisTextSpan('ด้วยตัวเอง!', isRed: true),
        ],
      });

  // ---- NEW Screen (between welcome and plan): Interval explainer ----
  List<EmphasisTextSpan> ex2WalkTitleSpans() => _spans({
        'ko': const [
          EmphasisTextSpan('30분 '),
          EmphasisTextSpan('천천히', isRed: true),
          EmphasisTextSpan(' 걷기'),
        ],
        'en': const [
          EmphasisTextSpan('30 min '),
          EmphasisTextSpan('slow', isRed: true),
          EmphasisTextSpan(' walk'),
        ],
        'es': const [
          EmphasisTextSpan('30 min '),
          EmphasisTextSpan('lento', isRed: true),
          EmphasisTextSpan(' caminar'),
        ],
        'fr': const [
          EmphasisTextSpan('30 min '),
          EmphasisTextSpan('lent', isRed: true),
          EmphasisTextSpan(' marcher'),
        ],
        'de': const [
          EmphasisTextSpan('30 Min. '),
          EmphasisTextSpan('langsam', isRed: true),
          EmphasisTextSpan(' gehen'),
        ],
        'it': const [
          EmphasisTextSpan('30 min '),
          EmphasisTextSpan('lento', isRed: true),
          EmphasisTextSpan(' camminare'),
        ],
        'nl': const [
          EmphasisTextSpan('30 min '),
          EmphasisTextSpan('rustig', isRed: true),
          EmphasisTextSpan(' wandelen'),
        ],
        'da': const [
          EmphasisTextSpan('30 min '),
          EmphasisTextSpan('roligt', isRed: true),
          EmphasisTextSpan(' gå'),
        ],
        'nb': const [
          EmphasisTextSpan('30 min '),
          EmphasisTextSpan('rolig', isRed: true),
          EmphasisTextSpan(' gange'),
        ],
        'ru': const [
          EmphasisTextSpan('30 мин '),
          EmphasisTextSpan('медленно', isRed: true),
          EmphasisTextSpan(' идти'),
        ],
        'pt': const [
          EmphasisTextSpan('30 min '),
          EmphasisTextSpan('devagar', isRed: true),
          EmphasisTextSpan(' caminhar'),
        ],
        'ja': const [
          EmphasisTextSpan('30分 '),
          EmphasisTextSpan('ゆっくり', isRed: true),
          EmphasisTextSpan('歩く'),
        ],
        'zh': const [
          EmphasisTextSpan('30分钟 '),
          EmphasisTextSpan('慢慢', isRed: true),
          EmphasisTextSpan('走'),
        ],
        'vi': const [
          EmphasisTextSpan('30 phút '),
          EmphasisTextSpan('chậm', isRed: true),
          EmphasisTextSpan(' đi bộ'),
        ],
        'ar': const [
          EmphasisTextSpan('30 دقيقة '),
          EmphasisTextSpan('ببطء', isRed: true),
          EmphasisTextSpan(' مشي'),
        ],
        'th': const [
          EmphasisTextSpan('30 นาที '),
          EmphasisTextSpan('ช้าๆ', isRed: true),
          EmphasisTextSpan(' เดิน'),
        ],
      });

  List<EmphasisTextSpan> ex2RunTitleSpans() => _spans({
        'ko': const [
          EmphasisTextSpan('10분 '),
          EmphasisTextSpan('빠르게', isRed: true),
          EmphasisTextSpan(' 뛰기'),
        ],
        'en': const [
          EmphasisTextSpan('10 min '),
          EmphasisTextSpan('fast', isRed: true),
          EmphasisTextSpan(' run'),
        ],
        'es': const [
          EmphasisTextSpan('10 min '),
          EmphasisTextSpan('rápido', isRed: true),
          EmphasisTextSpan(' correr'),
        ],
        'fr': const [
          EmphasisTextSpan('10 min '),
          EmphasisTextSpan('vite', isRed: true),
          EmphasisTextSpan(' courir'),
        ],
        'de': const [
          EmphasisTextSpan('10 Min. '),
          EmphasisTextSpan('schnell', isRed: true),
          EmphasisTextSpan(' laufen'),
        ],
        'it': const [
          EmphasisTextSpan('10 min '),
          EmphasisTextSpan('veloce', isRed: true),
          EmphasisTextSpan(' correre'),
        ],
        'nl': const [
          EmphasisTextSpan('10 min '),
          EmphasisTextSpan('snel', isRed: true),
          EmphasisTextSpan(' rennen'),
        ],
        'da': const [
          EmphasisTextSpan('10 min '),
          EmphasisTextSpan('hurtigt', isRed: true),
          EmphasisTextSpan(' løbe'),
        ],
        'nb': const [
          EmphasisTextSpan('10 min '),
          EmphasisTextSpan('fort', isRed: true),
          EmphasisTextSpan(' løpe'),
        ],
        'ru': const [
          EmphasisTextSpan('10 мин '),
          EmphasisTextSpan('быстро', isRed: true),
          EmphasisTextSpan(' бежать'),
        ],
        'pt': const [
          EmphasisTextSpan('10 min '),
          EmphasisTextSpan('rápido', isRed: true),
          EmphasisTextSpan(' correr'),
        ],
        'ja': const [
          EmphasisTextSpan('10分 '),
          EmphasisTextSpan('速く', isRed: true),
          EmphasisTextSpan('走る'),
        ],
        'zh': const [
          EmphasisTextSpan('10分钟 '),
          EmphasisTextSpan('快速', isRed: true),
          EmphasisTextSpan('跑'),
        ],
        'vi': const [
          EmphasisTextSpan('10 phút '),
          EmphasisTextSpan('nhanh', isRed: true),
          EmphasisTextSpan(' chạy'),
        ],
        'ar': const [
          EmphasisTextSpan('10 دقائق '),
          EmphasisTextSpan('سريعًا', isRed: true),
          EmphasisTextSpan(' جري'),
        ],
        'th': const [
          EmphasisTextSpan('10 นาที '),
          EmphasisTextSpan('เร็วๆ', isRed: true),
          EmphasisTextSpan(' วิ่ง'),
        ],
      });

  String ex2Question() => _t({
        'ko': '뭐가 더 살이 잘 빠질까요?',
        'en': 'Which burns fat better?',
        'es': '¿Qué quema más grasa?',
        'fr': 'Qu’est-ce qui brûle mieux les graisses ?',
        'de': 'Was verbrennt mehr Fett?',
        'it': 'Cosa fa dimagrire di più?',
        'nl': 'Wat verbrandt beter vet?',
        'da': 'Hvad forbrænder fedt bedst?',
        'nb': 'Hva forbrenner fett best?',
        'ru': 'Что лучше сжигает жир?',
        'pt': 'O que queima mais gordura?',
        'ja': 'どっちがより痩せる？',
        'zh': '哪个更减脂？',
        'vi': 'Cái nào giúp giảm mỡ tốt hơn?',
        'ar': 'أيّهما يحرق الدهون أكثر؟',
        'th': 'อะไรช่วยเผาผลาญไขมันได้ดีกว่า?',
      });

  List<String> ex2IntervalLines() => [
        _t({
          'ko': '2분 천천히 걷고,',
          'en': 'Walk slowly for 2 minutes,',
          'es': 'Camina lento 2 minutos,',
          'fr': 'Marche lentement 2 minutes,',
          'de': '2 Minuten langsam gehen,',
          'it': 'Cammina lentamente 2 minuti,',
          'nl': '2 minuten rustig wandelen,',
          'da': 'Gå roligt i 2 minutter,',
          'nb': 'Gå rolig i 2 minutter,',
          'ru': '2 минуты идти медленно,',
          'pt': 'Caminhe devagar por 2 minutos,',
          'ja': '2分ゆっくり歩いて、',
          'zh': '慢走2分钟，',
          'vi': 'Đi bộ chậm 2 phút,',
          'ar': 'امشِ ببطء لمدة دقيقتين،',
          'th': 'เดินช้าๆ 2 นาที,',
        }),
        _t({
          'ko': '3분 빠르게 뛰고,',
          'en': 'run fast for 3 minutes,',
          'es': 'corre rápido 3 minutos,',
          'fr': 'cours vite 3 minutes,',
          'de': '3 Minuten schnell laufen,',
          'it': 'corri veloce 3 minuti,',
          'nl': '3 minuten snel rennen,',
          'da': 'løb hurtigt i 3 minutter,',
          'nb': 'løp fort i 3 minutter,',
          'ru': '3 минуты бежать быстро,',
          'pt': 'corra rápido por 3 minutos,',
          'ja': '3分速く走って、',
          'zh': '快跑3分钟，',
          'vi': 'chạy nhanh 3 phút,',
          'ar': 'اركض بسرعة لمدة 3 دقائق،',
          'th': 'วิ่งเร็ว 3 นาที,',
        }),
        _t({
          'ko': '또 다시 2분 천천히 걷고,',
          'en': 'then walk slowly for 2 minutes again,',
          'es': 'luego camina lento 2 minutos otra vez,',
          'fr': 'puis marche lentement 2 minutes encore,',
          'de': 'dann wieder 2 Minuten langsam gehen,',
          'it': 'poi cammina lentamente 2 minuti di nuovo,',
          'nl': 'dan weer 2 minuten rustig wandelen,',
          'da': 'så igen gå roligt i 2 minutter,',
          'nb': 'så igjen gå rolig i 2 minutter,',
          'ru': 'потом снова 2 минуты идти медленно,',
          'pt': 'depois caminhe devagar por 2 minutos de novo,',
          'ja': 'また2分ゆっくり歩いて、',
          'zh': '再慢走2分钟，',
          'vi': 'rồi lại đi bộ chậm 2 phút,',
          'ar': 'ثم امشِ ببطء لمدة دقيقتين مرة أخرى،',
          'th': 'แล้วเดินช้าๆ 2 นาทีอีกครั้ง,',
        }),
        _t({
          'ko': '또 다시 3분 빠르게 뛰고,',
          'en': 'and run fast for 3 minutes again,',
          'es': 'y corre rápido 3 minutos otra vez,',
          'fr': 'et cours vite 3 minutes encore,',
          'de': 'und wieder 3 Minuten schnell laufen,',
          'it': 'e corri veloce 3 minuti di nuovo,',
          'nl': 'en weer 3 minuten snel rennen,',
          'da': 'og igen løb hurtigt i 3 minutter,',
          'nb': 'og igjen løp fort i 3 minutter,',
          'ru': 'и снова 3 минуты бежать быстро,',
          'pt': 'e corra rápido por 3 minutos de novo,',
          'ja': 'また3分速く走って、',
          'zh': '再快跑3分钟，',
          'vi': 'và lại chạy nhanh 3 phút,',
          'ar': 'ثم اركض بسرعة لمدة 3 دقائق مرة أخرى،',
          'th': 'แล้ววิ่งเร็ว 3 นาทีอีกครั้ง,',
        }),
      ];

  // Returns spans for highlighting key words in each interval line.
  List<EmphasisTextSpan>? ex2IntervalHighlightSpans(int idx) {
    switch (code) {
      case 'ko':
        switch (idx) {
          case 0:
            return const [
              EmphasisTextSpan('2분 천천히 ', isRed: false),
              EmphasisTextSpan('걷고', isRed: true),
              EmphasisTextSpan(',', isRed: false),
            ];
          case 1:
            return const [
              EmphasisTextSpan('3분 ', isRed: false),
              EmphasisTextSpan('빠르게', isRed: true),
              EmphasisTextSpan(' 뛰고,', isRed: false),
            ];
          case 2:
            return const [
              EmphasisTextSpan('또 다시 2분 천천히 ', isRed: false),
              EmphasisTextSpan('걷고', isRed: true),
              EmphasisTextSpan(',', isRed: false),
            ];
          case 3:
            return const [
              EmphasisTextSpan('또 다시 3분 ', isRed: false),
              EmphasisTextSpan('빠르게', isRed: true),
              EmphasisTextSpan(' 뛰고,', isRed: false),
            ];
        }
        break;
      case 'en':
        switch (idx) {
          case 0:
            return const [
              EmphasisTextSpan('Walk ', isRed: false),
              EmphasisTextSpan('slowly', isRed: true),
              EmphasisTextSpan(' for 2 minutes,', isRed: false),
            ];
          case 1:
            return const [
              EmphasisTextSpan('run ', isRed: false),
              EmphasisTextSpan('fast', isRed: true),
              EmphasisTextSpan(' for 3 minutes,', isRed: false),
            ];
          case 2:
            return const [
              EmphasisTextSpan('then walk ', isRed: false),
              EmphasisTextSpan('slowly', isRed: true),
              EmphasisTextSpan(' for 2 minutes again,', isRed: false),
            ];
          case 3:
            return const [
              EmphasisTextSpan('and run ', isRed: false),
              EmphasisTextSpan('fast', isRed: true),
              EmphasisTextSpan(' for 3 minutes again,', isRed: false),
            ];
        }
        break;
      case 'es':
        switch (idx) {
          case 0:
            return const [
              EmphasisTextSpan('Camina ', isRed: false),
              EmphasisTextSpan('lento', isRed: true),
              EmphasisTextSpan(' 2 minutos,', isRed: false),
            ];
          case 1:
            return const [
              EmphasisTextSpan('corre ', isRed: false),
              EmphasisTextSpan('rápido', isRed: true),
              EmphasisTextSpan(' 3 minutos,', isRed: false),
            ];
          case 2:
            return const [
              EmphasisTextSpan('luego camina ', isRed: false),
              EmphasisTextSpan('lento', isRed: true),
              EmphasisTextSpan(' 2 minutos otra vez,', isRed: false),
            ];
          case 3:
            return const [
              EmphasisTextSpan('y corre ', isRed: false),
              EmphasisTextSpan('rápido', isRed: true),
              EmphasisTextSpan(' 3 minutos otra vez,', isRed: false),
            ];
        }
        break;
      case 'fr':
        switch (idx) {
          case 0:
            return const [
              EmphasisTextSpan('Marche ', isRed: false),
              EmphasisTextSpan('lentement', isRed: true),
              EmphasisTextSpan(' 2 minutes,', isRed: false),
            ];
          case 1:
            return const [
              EmphasisTextSpan('cours ', isRed: false),
              EmphasisTextSpan('vite', isRed: true),
              EmphasisTextSpan(' 3 minutes,', isRed: false),
            ];
          case 2:
            return const [
              EmphasisTextSpan('puis marche ', isRed: false),
              EmphasisTextSpan('lentement', isRed: true),
              EmphasisTextSpan(' 2 minutes encore,', isRed: false),
            ];
          case 3:
            return const [
              EmphasisTextSpan('et cours ', isRed: false),
              EmphasisTextSpan('vite', isRed: true),
              EmphasisTextSpan(' 3 minutes encore,', isRed: false),
            ];
        }
        break;
      case 'de':
        switch (idx) {
          case 0:
            return const [
              EmphasisTextSpan('2 Minuten ', isRed: false),
              EmphasisTextSpan('langsam', isRed: true),
              EmphasisTextSpan(' gehen,', isRed: false),
            ];
          case 1:
            return const [
              EmphasisTextSpan('3 Minuten ', isRed: false),
              EmphasisTextSpan('schnell', isRed: true),
              EmphasisTextSpan(' laufen,', isRed: false),
            ];
          case 2:
            return const [
              EmphasisTextSpan('dann wieder 2 Minuten ', isRed: false),
              EmphasisTextSpan('langsam', isRed: true),
              EmphasisTextSpan(' gehen,', isRed: false),
            ];
          case 3:
            return const [
              EmphasisTextSpan('und wieder 3 Minuten ', isRed: false),
              EmphasisTextSpan('schnell', isRed: true),
              EmphasisTextSpan(' laufen,', isRed: false),
            ];
        }
        break;
      case 'it':
        switch (idx) {
          case 0:
            return const [
              EmphasisTextSpan('Cammina ', isRed: false),
              EmphasisTextSpan('lentamente', isRed: true),
              EmphasisTextSpan(' 2 minuti,', isRed: false),
            ];
          case 1:
            return const [
              EmphasisTextSpan('corri ', isRed: false),
              EmphasisTextSpan('veloce', isRed: true),
              EmphasisTextSpan(' 3 minuti,', isRed: false),
            ];
          case 2:
            return const [
              EmphasisTextSpan('poi cammina ', isRed: false),
              EmphasisTextSpan('lentamente', isRed: true),
              EmphasisTextSpan(' 2 minuti di nuovo,', isRed: false),
            ];
          case 3:
            return const [
              EmphasisTextSpan('e corri ', isRed: false),
              EmphasisTextSpan('veloce', isRed: true),
              EmphasisTextSpan(' 3 minuti di nuovo,', isRed: false),
            ];
        }
        break;
      case 'nl':
        switch (idx) {
          case 0:
            return const [
              EmphasisTextSpan('2 minuten ', isRed: false),
              EmphasisTextSpan('rustig', isRed: true),
              EmphasisTextSpan(' wandelen,', isRed: false),
            ];
          case 1:
            return const [
              EmphasisTextSpan('3 minuten ', isRed: false),
              EmphasisTextSpan('snel', isRed: true),
              EmphasisTextSpan(' rennen,', isRed: false),
            ];
          case 2:
            return const [
              EmphasisTextSpan('dan weer 2 minuten ', isRed: false),
              EmphasisTextSpan('rustig', isRed: true),
              EmphasisTextSpan(' wandelen,', isRed: false),
            ];
          case 3:
            return const [
              EmphasisTextSpan('en weer 3 minuten ', isRed: false),
              EmphasisTextSpan('snel', isRed: true),
              EmphasisTextSpan(' rennen,', isRed: false),
            ];
        }
        break;
      case 'da':
        switch (idx) {
          case 0:
            return const [
              EmphasisTextSpan('Gå ', isRed: false),
              EmphasisTextSpan('roligt', isRed: true),
              EmphasisTextSpan(' i 2 minutter,', isRed: false),
            ];
          case 1:
            return const [
              EmphasisTextSpan('løb ', isRed: false),
              EmphasisTextSpan('hurtigt', isRed: true),
              EmphasisTextSpan(' i 3 minutter,', isRed: false),
            ];
          case 2:
            return const [
              EmphasisTextSpan('så igen gå ', isRed: false),
              EmphasisTextSpan('roligt', isRed: true),
              EmphasisTextSpan(' i 2 minutter,', isRed: false),
            ];
          case 3:
            return const [
              EmphasisTextSpan('og igen løb ', isRed: false),
              EmphasisTextSpan('hurtigt', isRed: true),
              EmphasisTextSpan(' i 3 minutter,', isRed: false),
            ];
        }
        break;
      case 'nb':
        switch (idx) {
          case 0:
            return const [
              EmphasisTextSpan('Gå ', isRed: false),
              EmphasisTextSpan('rolig', isRed: true),
              EmphasisTextSpan(' i 2 minutter,', isRed: false),
            ];
          case 1:
            return const [
              EmphasisTextSpan('løp ', isRed: false),
              EmphasisTextSpan('fort', isRed: true),
              EmphasisTextSpan(' i 3 minutter,', isRed: false),
            ];
          case 2:
            return const [
              EmphasisTextSpan('så igjen gå ', isRed: false),
              EmphasisTextSpan('rolig', isRed: true),
              EmphasisTextSpan(' i 2 minutter,', isRed: false),
            ];
          case 3:
            return const [
              EmphasisTextSpan('og igjen løp ', isRed: false),
              EmphasisTextSpan('fort', isRed: true),
              EmphasisTextSpan(' i 3 minutter,', isRed: false),
            ];
        }
        break;
      case 'ru':
        switch (idx) {
          case 0:
            return const [
              EmphasisTextSpan('2 минуты идти ', isRed: false),
              EmphasisTextSpan('медленно', isRed: true),
              EmphasisTextSpan(',', isRed: false),
            ];
          case 1:
            return const [
              EmphasisTextSpan('3 минуты бежать ', isRed: false),
              EmphasisTextSpan('быстро', isRed: true),
              EmphasisTextSpan(',', isRed: false),
            ];
          case 2:
            return const [
              EmphasisTextSpan('потом снова 2 минуты идти ', isRed: false),
              EmphasisTextSpan('медленно', isRed: true),
              EmphasisTextSpan(',', isRed: false),
            ];
          case 3:
            return const [
              EmphasisTextSpan('и снова 3 минуты бежать ', isRed: false),
              EmphasisTextSpan('быстро', isRed: true),
              EmphasisTextSpan(',', isRed: false),
            ];
        }
        break;
      case 'pt':
        switch (idx) {
          case 0:
            return const [
              EmphasisTextSpan('Caminhe ', isRed: false),
              EmphasisTextSpan('devagar', isRed: true),
              EmphasisTextSpan(' por 2 minutos,', isRed: false),
            ];
          case 1:
            return const [
              EmphasisTextSpan('corra ', isRed: false),
              EmphasisTextSpan('rápido', isRed: true),
              EmphasisTextSpan(' por 3 minutos,', isRed: false),
            ];
          case 2:
            return const [
              EmphasisTextSpan('depois caminhe ', isRed: false),
              EmphasisTextSpan('devagar', isRed: true),
              EmphasisTextSpan(' por 2 minutos de novo,', isRed: false),
            ];
          case 3:
            return const [
              EmphasisTextSpan('e corra ', isRed: false),
              EmphasisTextSpan('rápido', isRed: true),
              EmphasisTextSpan(' por 3 minutos de novo,', isRed: false),
            ];
        }
        break;
      case 'ja':
        switch (idx) {
          case 0:
            return const [
              EmphasisTextSpan('2分', isRed: false),
              EmphasisTextSpan('ゆっくり', isRed: true),
              EmphasisTextSpan('歩いて、', isRed: false),
            ];
          case 1:
            return const [
              EmphasisTextSpan('3分', isRed: false),
              EmphasisTextSpan('速く', isRed: true),
              EmphasisTextSpan('走って、', isRed: false),
            ];
          case 2:
            return const [
              EmphasisTextSpan('また2分', isRed: false),
              EmphasisTextSpan('ゆっくり', isRed: true),
              EmphasisTextSpan('歩いて、', isRed: false),
            ];
          case 3:
            return const [
              EmphasisTextSpan('また3分', isRed: false),
              EmphasisTextSpan('速く', isRed: true),
              EmphasisTextSpan('走って、', isRed: false),
            ];
        }
        break;
      case 'zh':
        switch (idx) {
          case 0:
            return const [
              EmphasisTextSpan('慢走', isRed: true),
              EmphasisTextSpan('2分钟，', isRed: false),
            ];
          case 1:
            return const [
              EmphasisTextSpan('快跑', isRed: true),
              EmphasisTextSpan('3分钟，', isRed: false),
            ];
          case 2:
            return const [
              EmphasisTextSpan('再慢走', isRed: true),
              EmphasisTextSpan('2分钟，', isRed: false),
            ];
          case 3:
            return const [
              EmphasisTextSpan('再快跑', isRed: true),
              EmphasisTextSpan('3分钟，', isRed: false),
            ];
        }
        break;
      case 'vi':
        switch (idx) {
          case 0:
            return const [
              EmphasisTextSpan('Đi bộ ', isRed: false),
              EmphasisTextSpan('chậm', isRed: true),
              EmphasisTextSpan(' 2 phút,', isRed: false),
            ];
          case 1:
            return const [
              EmphasisTextSpan('chạy ', isRed: false),
              EmphasisTextSpan('nhanh', isRed: true),
              EmphasisTextSpan(' 3 phút,', isRed: false),
            ];
          case 2:
            return const [
              EmphasisTextSpan('rồi lại đi bộ ', isRed: false),
              EmphasisTextSpan('chậm', isRed: true),
              EmphasisTextSpan(' 2 phút,', isRed: false),
            ];
          case 3:
            return const [
              EmphasisTextSpan('và lại chạy ', isRed: false),
              EmphasisTextSpan('nhanh', isRed: true),
              EmphasisTextSpan(' 3 phút,', isRed: false),
            ];
        }
        break;
      case 'ar':
        switch (idx) {
          case 0:
            return const [
              EmphasisTextSpan('امشِ ', isRed: false),
              EmphasisTextSpan('ببطء', isRed: true),
              EmphasisTextSpan(' لمدة دقيقتين،', isRed: false),
            ];
          case 1:
            return const [
              EmphasisTextSpan('اركض ', isRed: false),
              EmphasisTextSpan('بسرعة', isRed: true),
              EmphasisTextSpan(' لمدة 3 دقائق،', isRed: false),
            ];
          case 2:
            return const [
              EmphasisTextSpan('ثم امشِ ', isRed: false),
              EmphasisTextSpan('ببطء', isRed: true),
              EmphasisTextSpan(' لمدة دقيقتين مرة أخرى،', isRed: false),
            ];
          case 3:
            return const [
              EmphasisTextSpan('ثم اركض ', isRed: false),
              EmphasisTextSpan('بسرعة', isRed: true),
              EmphasisTextSpan(' لمدة 3 دقائق مرة أخرى،', isRed: false),
            ];
        }
        break;
      case 'th':
        switch (idx) {
          case 0:
            return const [
              EmphasisTextSpan('เดินช้าๆ ', isRed: true),
              EmphasisTextSpan('2 นาที,', isRed: false),
            ];
          case 1:
            return const [
              EmphasisTextSpan('วิ่งเร็ว ', isRed: true),
              EmphasisTextSpan('3 นาที,', isRed: false),
            ];
          case 2:
            return const [
              EmphasisTextSpan('แล้วเดินช้าๆ ', isRed: true),
              EmphasisTextSpan('2 นาทีอีกครั้ง,', isRed: false),
            ];
          case 3:
            return const [
              EmphasisTextSpan('แล้ววิ่งเร็ว ', isRed: true),
              EmphasisTextSpan('3 นาทีอีกครั้ง,', isRed: false),
            ];
        }
        break;
    }
    return null;
  }

  List<EmphasisTextSpan> ex2FinalSpans() => _spans({
        'ko': const [
          EmphasisTextSpan('이렇게 '),
          EmphasisTextSpan('30분씩', isRed: true),
          EmphasisTextSpan(','),
          EmphasisTextSpan('이게 더 잘 '),
          EmphasisTextSpan('빠집니다'),
        ],
        'en': const [
          EmphasisTextSpan('Like this, for '),
          EmphasisTextSpan('30 minutes', isRed: true),
          EmphasisTextSpan(','),
          EmphasisTextSpan(' this works better'),
          EmphasisTextSpan(''),
        ],
      });

  List<EmphasisTextSpan> ex2FinalLine1Spans() => _spans({
        'ko': const [
          EmphasisTextSpan('이렇게 '),
          EmphasisTextSpan('30분씩', isRed: true),
          EmphasisTextSpan(','),
        ],
        'en': const [
          EmphasisTextSpan('Like this, for '),
          EmphasisTextSpan('30 minutes', isRed: true),
          EmphasisTextSpan(','),
        ],
        'es': const [
          EmphasisTextSpan('Así, por '),
          EmphasisTextSpan('30 minutos', isRed: true),
          EmphasisTextSpan(','),
        ],
        'fr': const [
          EmphasisTextSpan('Ainsi, pendant '),
          EmphasisTextSpan('30 minutes', isRed: true),
          EmphasisTextSpan(','),
        ],
        'de': const [
          EmphasisTextSpan('So, für '),
          EmphasisTextSpan('30 Minuten', isRed: true),
          EmphasisTextSpan(','),
        ],
        'it': const [
          EmphasisTextSpan('Così, per '),
          EmphasisTextSpan('30 minuti', isRed: true),
          EmphasisTextSpan(','),
        ],
        'nl': const [
          EmphasisTextSpan('Zo, '),
          EmphasisTextSpan('30 minuten', isRed: true),
          EmphasisTextSpan(','),
        ],
        'da': const [
          EmphasisTextSpan('Sådan, i '),
          EmphasisTextSpan('30 minutter', isRed: true),
          EmphasisTextSpan(','),
        ],
        'nb': const [
          EmphasisTextSpan('Slik, i '),
          EmphasisTextSpan('30 minutter', isRed: true),
          EmphasisTextSpan(','),
        ],
        'ru': const [
          EmphasisTextSpan('Вот так, '),
          EmphasisTextSpan('30 минут', isRed: true),
          EmphasisTextSpan(','),
        ],
        'pt': const [
          EmphasisTextSpan('Assim, por '),
          EmphasisTextSpan('30 minutos', isRed: true),
          EmphasisTextSpan(','),
        ],
        'ja': const [
          EmphasisTextSpan('こうして'),
          EmphasisTextSpan('30分', isRed: true),
          EmphasisTextSpan('、'),
        ],
        'zh': const [
          EmphasisTextSpan('这样每次'),
          EmphasisTextSpan('30分钟', isRed: true),
          EmphasisTextSpan('，'),
        ],
        'vi': const [
          EmphasisTextSpan('Như vậy, '),
          EmphasisTextSpan('30 phút', isRed: true),
          EmphasisTextSpan(','),
        ],
        'ar': const [
          EmphasisTextSpan('هكذا لمدة '),
          EmphasisTextSpan('30 دقيقة', isRed: true),
          EmphasisTextSpan('،'),
        ],
        'th': const [
          EmphasisTextSpan('แบบนี้ครั้งละ '),
          EmphasisTextSpan('30 นาที', isRed: true),
          EmphasisTextSpan(','),
        ],
      });

  List<EmphasisTextSpan> ex2FinalLine2Spans() => _spans({
        'ko': const [
          EmphasisTextSpan('이게 더 잘 빠집니다'),
        ],
        'en': const [
          EmphasisTextSpan('this works better.'),
        ],
        'es': const [
          EmphasisTextSpan('esto funciona mejor.'),
        ],
        'fr': const [
          EmphasisTextSpan('c’est plus efficace.'),
        ],
        'de': const [
          EmphasisTextSpan('das wirkt besser.'),
        ],
        'it': const [
          EmphasisTextSpan('funziona meglio.'),
        ],
        'nl': const [
          EmphasisTextSpan('werkt dit beter.'),
        ],
        'da': const [
          EmphasisTextSpan('virker det bedre.'),
        ],
        'nb': const [
          EmphasisTextSpan('fungerer det bedre.'),
        ],
        'ru': const [
          EmphasisTextSpan('это работает лучше.'),
        ],
        'pt': const [
          EmphasisTextSpan('funciona melhor.'),
        ],
        'ja': const [
          EmphasisTextSpan('こちらのほうが効果的です'),
        ],
        'zh': const [
          EmphasisTextSpan('这样更有效'),
        ],
        'vi': const [
          EmphasisTextSpan('sẽ hiệu quả hơn.'),
        ],
        'ar': const [
          EmphasisTextSpan('هذا أكثر فاعلية.'),
        ],
        'th': const [
          EmphasisTextSpan('จะได้ผลดีกว่า'),
        ],
      });

  String planTotalWorkoutTimeLabel() => _t({
        'ko': '총 운동 시간',
        'en': 'Total workout time',
        'es': 'Tiempo total',
        'fr': 'Temps total',
        'de': 'Gesamtzeit',
        'it': 'Tempo totale',
        'nl': 'Totale tijd',
        'da': 'Samlet tid',
        'nb': 'Total tid',
        'ru': 'Общее время',
        'pt': 'Tempo total',
        'ja': '合計時間',
        'zh': '总时长',
        'vi': 'Tổng thời gian',
        'ar': 'الوقت الإجمالي',
        'th': 'เวลารวม',
      });

  String setLabel(int n) {
    final template = _t({
      'ko': '{n}세트',
      'en': 'Set {n}',
      'es': 'Serie {n}',
      'fr': 'Série {n}',
      'de': 'Satz {n}',
      'it': 'Serie {n}',
      'nl': 'Set {n}',
      'da': 'Sæt {n}',
      'nb': 'Sett {n}',
      'ru': 'Подход {n}',
      'pt': 'Série {n}',
      'ja': '{n}セット',
      'zh': '第{n}组',
      'vi': 'Hiệp {n}',
      'ar': 'مجموعة {n}',
      'th': 'เซ็ต {n}',
    });
    return template.replaceAll('{n}', n.toString());
  }

  // ---- Screen 3 ----
  List<EmphasisTextSpan> s3TitleSpans() => _spans({
        'ko': const [
          EmphasisTextSpan('속도와 시간을 보고\n'),
          EmphasisTextSpan('루틴에 맞춰', isRed: true),
          EmphasisTextSpan(' 운동해보세요'),
        ],
        'en': const [
          EmphasisTextSpan('Check speed & time,\n'),
          EmphasisTextSpan('follow your routine', isRed: true),
          EmphasisTextSpan(' as you train.'),
        ],
        'es': const [
          EmphasisTextSpan('Mira velocidad y tiempo,\n'),
          EmphasisTextSpan('sigue tu rutina', isRed: true),
          EmphasisTextSpan(' al entrenar.'),
        ],
        'fr': const [
          EmphasisTextSpan('Regarde vitesse et temps,\n'),
          EmphasisTextSpan('suis ta routine', isRed: true),
          EmphasisTextSpan(' pendant l’entraînement.'),
        ],
        'de': const [
          EmphasisTextSpan('Sieh Tempo & Zeit,\n'),
          EmphasisTextSpan('trainiere nach Routine', isRed: true),
          EmphasisTextSpan('.'),
        ],
        'it': const [
          EmphasisTextSpan('Guarda velocità e tempo,\n'),
          EmphasisTextSpan('segui la routine', isRed: true),
          EmphasisTextSpan(' mentre ti alleni.'),
        ],
        'nl': const [
          EmphasisTextSpan('Bekijk snelheid en tijd,\n'),
          EmphasisTextSpan('train volgens je routine', isRed: true),
          EmphasisTextSpan('.'),
        ],
        'da': const [
          EmphasisTextSpan('Se hastighed og tid,\n'),
          EmphasisTextSpan('træn efter rutinen', isRed: true),
          EmphasisTextSpan('.'),
        ],
        'nb': const [
          EmphasisTextSpan('Se hastighet og tid,\n'),
          EmphasisTextSpan('tren etter rutinen', isRed: true),
          EmphasisTextSpan('.'),
        ],
        'ru': const [
          EmphasisTextSpan('Смотри скорость и время,\n'),
          EmphasisTextSpan('тренируйся по рутине', isRed: true),
          EmphasisTextSpan('.'),
        ],
        'pt': const [
          EmphasisTextSpan('Veja velocidade e tempo,\n'),
          EmphasisTextSpan('treine no ritmo da rotina', isRed: true),
          EmphasisTextSpan('.'),
        ],
        'ja': const [
          EmphasisTextSpan('速度と時間を見て\n'),
          EmphasisTextSpan('ルーティン通り', isRed: true),
          EmphasisTextSpan('に運動しよう'),
        ],
        'zh': const [
          EmphasisTextSpan('看速度和时间\n'),
          EmphasisTextSpan('按训练计划', isRed: true),
          EmphasisTextSpan('完成训练'),
        ],
        'vi': const [
          EmphasisTextSpan('Xem tốc độ và thời gian,\n'),
          EmphasisTextSpan('tập theo đúng routine', isRed: true),
          EmphasisTextSpan('.'),
        ],
        'ar': const [
          EmphasisTextSpan('راقب السرعة والوقت\n'),
          EmphasisTextSpan('واتبع روتينك', isRed: true),
          EmphasisTextSpan(' أثناء التمرين'),
        ],
        'th': const [
          EmphasisTextSpan('ดูความเร็วและเวลา\n'),
          EmphasisTextSpan('ออกกำลังกายตามรูทีน', isRed: true),
          EmphasisTextSpan('ของคุณ'),
        ],
      });

  String chipNextSpeed(String v) => _t({
        'ko': '다음 {v}',
        'en': 'Next {v}',
        'es': 'Siguiente {v}',
        'fr': 'Suivant {v}',
        'de': 'Als Nächstes {v}',
        'it': 'Prossimo {v}',
        'nl': 'Volgende {v}',
        'da': 'Næste {v}',
        'nb': 'Neste {v}',
        'ru': 'Далее {v}',
        'pt': 'Próximo {v}',
        'ja': '次は {v}',
        'zh': '下一项 {v}',
        'vi': 'Tiếp theo {v}',
        'ar': 'التالي {v}',
        'th': 'ถัดไป {v}',
      }).replaceAll('{v}', v);

  String chipIncline(String v) => _t({
        'ko': '{v} 경사도',
        'en': '{v} incline',
        'es': 'Inclinación {v}',
        'fr': 'Inclinaison {v}',
        'de': '{v} Steigung',
        'it': 'Inclinazione {v}',
        'nl': '{v} helling',
        'da': '{v} hældning',
        'nb': '{v} stigning',
        'ru': 'Наклон {v}',
        'pt': 'Inclinação {v}',
        'ja': '{v} 傾斜',
        'zh': '{v} 坡度',
        'vi': 'Độ dốc {v}',
        'ar': 'ميل {v}',
        'th': 'ความชัน {v}',
      }).replaceAll('{v}', v);

  // ---- Screen 4 ----
  List<EmphasisTextSpan> s4TitleSpans() => _spans({
        'ko': const [
          EmphasisTextSpan('운동이 끝난 후엔\n'),
          EmphasisTextSpan('그동안 완료한 운동들을 ', isRed: true),
          EmphasisTextSpan('기록하세요'),
        ],
        'en': const [
          EmphasisTextSpan('After your workout,\n'),
          EmphasisTextSpan('track what you completed', isRed: true),
          EmphasisTextSpan('.'),
        ],
        'es': const [
          EmphasisTextSpan('Después de entrenar,\n'),
          EmphasisTextSpan('registra lo que completaste', isRed: true),
          EmphasisTextSpan('.'),
        ],
        'fr': const [
          EmphasisTextSpan('Après l’entraînement,\n'),
          EmphasisTextSpan('enregistre tes séances', isRed: true),
          EmphasisTextSpan('.'),
        ],
        'de': const [
          EmphasisTextSpan('Nach dem Training,\n'),
          EmphasisTextSpan('halte deine Workouts fest', isRed: true),
          EmphasisTextSpan('.'),
        ],
        'it': const [
          EmphasisTextSpan('Dopo l’allenamento,\n'),
          EmphasisTextSpan('registra ciò che hai completato', isRed: true),
          EmphasisTextSpan('.'),
        ],
        'nl': const [
          EmphasisTextSpan('Na je workout,\n'),
          EmphasisTextSpan('leg je voltooide trainingen vast', isRed: true),
          EmphasisTextSpan('.'),
        ],
        'da': const [
          EmphasisTextSpan('Efter træningen,\n'),
          EmphasisTextSpan('registrér dine gennemførte træninger', isRed: true),
          EmphasisTextSpan('.'),
        ],
        'nb': const [
          EmphasisTextSpan('Etter økten,\n'),
          EmphasisTextSpan('registrer treningen du fullførte', isRed: true),
          EmphasisTextSpan('.'),
        ],
        'ru': const [
          EmphasisTextSpan('После тренировки,\n'),
          EmphasisTextSpan('сохраняй выполненные тренировки', isRed: true),
          EmphasisTextSpan('.'),
        ],
        'pt': const [
          EmphasisTextSpan('Depois do treino,\n'),
          EmphasisTextSpan('registre o que você concluiu', isRed: true),
          EmphasisTextSpan('.'),
        ],
        'ja': const [
          EmphasisTextSpan('運動が終わったら\n'),
          EmphasisTextSpan('完了した運動を記録', isRed: true),
          EmphasisTextSpan('しよう'),
        ],
        'zh': const [
          EmphasisTextSpan('训练结束后\n'),
          EmphasisTextSpan('记录已完成的训练', isRed: true),
          EmphasisTextSpan(''),
        ],
        'vi': const [
          EmphasisTextSpan('Sau khi tập xong,\n'),
          EmphasisTextSpan('ghi lại những buổi đã hoàn thành', isRed: true),
          EmphasisTextSpan('.'),
        ],
        'ar': const [
          EmphasisTextSpan('بعد التمرين،\n'),
          EmphasisTextSpan('سجّل ما أنجزته', isRed: true),
          EmphasisTextSpan('.'),
        ],
        'th': const [
          EmphasisTextSpan('หลังออกกำลังกายเสร็จ\n'),
          EmphasisTextSpan('บันทึกสิ่งที่คุณทำสำเร็จ', isRed: true),
          EmphasisTextSpan(''),
        ],
      });

  // History list mock strings
  List<({String title, String subtitle})> historyItems() => [
        (
          title: _t({
            'ko': '러닝 인터벌 루틴 1',
            'en': 'Treadmill Interval Routine 1',
          }),
          subtitle: _historySubRun(time: '30:00', dist: '4.52', avg: '8.5'),
        ),
        (
          title: _t({
            'ko': '러닝 인터벌 루틴 2',
            'en': 'Treadmill Interval Routine 2',
          }),
          subtitle: _historySubRun(time: '15:00', dist: '2.4', avg: '5.0'),
        ),
        (
          title: _t({
            'ko': '러닝 인터벌 루틴 3',
            'en': 'Treadmill Interval Routine 3',
          }),
          subtitle: _historySubRun(time: '20:00', dist: '5.8', avg: '7.5'),
        ),
        (
          title: _t({
            'ko': '사이클 인터벌 루틴 2',
            'en': 'Cycle Interval Routine 2',
          }),
          subtitle: historySubCycle(),
        ),
        (
          title: _t({
            'ko': '천국의 계단 인터벌 루틴 1',
            'en': 'Stairmaster Interval Routine 1',
          }),
          subtitle: historySubStair(),
        ),
      ];

  String _historySubRun({
    required String time,
    required String dist,
    required String avg,
  }) {
    final template = _t({
      'ko': '{time} • {dist} km • 평균 {avg} km/h',
      'en': '{time} • {dist} km • Avg. {avg} km/h',
      'es': '{time} • {dist} km • Prom. {avg} km/h',
      'fr': '{time} • {dist} km • Moy. {avg} km/h',
      'de': '{time} • {dist} km • Ø {avg} km/h',
      'it': '{time} • {dist} km • Media {avg} km/h',
      'nl': '{time} • {dist} km • Gem. {avg} km/h',
      'da': '{time} • {dist} km • Gns. {avg} km/t',
      'nb': '{time} • {dist} km • Snitt {avg} km/t',
      'ru': '{time} • {dist} km • Ср. {avg} km/h',
      'pt': '{time} • {dist} km • Média {avg} km/h',
      'ja': '{time} • {dist} km • 平均 {avg} km/h',
      'zh': '{time} • {dist} km • 平均 {avg} km/h',
      'vi': '{time} • {dist} km • TB {avg} km/h',
      'ar': '{time} • {dist} km • متوسط {avg} km/h',
      'th': '{time} • {dist} km • เฉลี่ย {avg} km/h',
    });
    return template
        .replaceAll('{time}', time)
        .replaceAll('{dist}', dist)
        .replaceAll('{avg}', avg);
  }

  String historySubCycle() => _t({
        'ko': '30:00 • 평균 RPM 75',
        'en': '30:00 • Avg RPM 75',
        'es': '30:00 • RPM prom. 75',
        'fr': '30:00 • RPM moy. 75',
        'de': '30:00 • Ø RPM 75',
        'it': '30:00 • RPM medi 75',
        'nl': '30:00 • Gem. RPM 75',
        'da': '30:00 • Gns. RPM 75',
        'nb': '30:00 • Snitt RPM 75',
        'ru': '30:00 • Ср. RPM 75',
        'pt': '30:00 • RPM méd. 75',
        'ja': '30:00 • 平均 RPM 75',
        'zh': '30:00 • 平均 RPM 75',
        'vi': '30:00 • RPM TB 75',
        'ar': '30:00 • متوسط RPM 75',
        'th': '30:00 • RPM เฉลี่ย 75',
      });

  String historySubStair() => _t({
        'ko': '30:00 • 평균 레벨 8.5',
        'en': '30:00 • Avg Level 8.5',
        'es': '30:00 • Nivel prom. 8.5',
        'fr': '30:00 • Niveau moy. 8.5',
        'de': '30:00 • Ø Stufe 8.5',
        'it': '30:00 • Livello medio 8.5',
        'nl': '30:00 • Gem. niveau 8.5',
        'da': '30:00 • Gns. niveau 8.5',
        'nb': '30:00 • Snittnivå 8.5',
        'ru': '30:00 • Ср. уровень 8.5',
        'pt': '30:00 • Nível méd. 8.5',
        'ja': '30:00 • 平均 レベル 8.5',
        'zh': '30:00 • 平均 等级 8.5',
        'vi': '30:00 • Cấp TB 8.5',
        'ar': '30:00 • متوسط المستوى 8.5',
        'th': '30:00 • ระดับเฉลี่ย 8.5',
      });

  // ---- Screen 5 ----
  List<EmphasisTextSpan> s5TitleSpans() => _spans({
        'ko': const [
          EmphasisTextSpan('자신의 '),
          EmphasisTextSpan('운동 레벨', isRed: true),
          EmphasisTextSpan('을 선택해 주세요'),
        ],
        'en': const [
          EmphasisTextSpan('Select your '),
          EmphasisTextSpan('fitness level', isRed: true),
          EmphasisTextSpan('.'),
        ],
        'es': const [
          EmphasisTextSpan('Elige tu '),
          EmphasisTextSpan('nivel', isRed: true),
          EmphasisTextSpan(' de entrenamiento'),
        ],
        'fr': const [
          EmphasisTextSpan('Choisis ton '),
          EmphasisTextSpan('niveau', isRed: true),
          EmphasisTextSpan(''),
        ],
        'de': const [
          EmphasisTextSpan('Wähle dein '),
          EmphasisTextSpan('Fitnesslevel', isRed: true),
          EmphasisTextSpan(''),
        ],
        'it': const [
          EmphasisTextSpan('Seleziona il tuo '),
          EmphasisTextSpan('livello', isRed: true),
          EmphasisTextSpan(''),
        ],
        'nl': const [
          EmphasisTextSpan('Kies je '),
          EmphasisTextSpan('niveau', isRed: true),
          EmphasisTextSpan(''),
        ],
        'da': const [
          EmphasisTextSpan('Vælg dit '),
          EmphasisTextSpan('niveau', isRed: true),
          EmphasisTextSpan(''),
        ],
        'nb': const [
          EmphasisTextSpan('Velg ditt '),
          EmphasisTextSpan('nivå', isRed: true),
          EmphasisTextSpan(''),
        ],
        'ru': const [
          EmphasisTextSpan('Выбери '),
          EmphasisTextSpan('уровень', isRed: true),
          EmphasisTextSpan(''),
        ],
        'pt': const [
          EmphasisTextSpan('Escolha seu '),
          EmphasisTextSpan('nível', isRed: true),
          EmphasisTextSpan(''),
        ],
        'ja': const [
          EmphasisTextSpan('自分の'),
          EmphasisTextSpan('レベル', isRed: true),
          EmphasisTextSpan('を選択してください'),
        ],
        'zh': const [
          EmphasisTextSpan('选择你的'),
          EmphasisTextSpan('训练水平', isRed: true),
          EmphasisTextSpan(''),
        ],
        'vi': const [
          EmphasisTextSpan('Chọn '),
          EmphasisTextSpan('cấp độ', isRed: true),
          EmphasisTextSpan(' của bạn'),
        ],
        'ar': const [
          EmphasisTextSpan('اختر '),
          EmphasisTextSpan('مستواك', isRed: true),
          EmphasisTextSpan(''),
        ],
        'th': const [
          EmphasisTextSpan('เลือก'),
          EmphasisTextSpan('ระดับ', isRed: true),
          EmphasisTextSpan('ของคุณ'),
        ],
      });

  String levelBeginnerTitle() => _t({
        'ko': '초급',
        'en': 'Beginner',
        'es': 'Principiante',
        'fr': 'Débutant',
        'de': 'Anfänger',
        'it': 'Principiante',
        'nl': 'Beginner',
        'da': 'Begynder',
        'nb': 'Nybegynner',
        'ru': 'Новичок',
        'pt': 'Iniciante',
        'ja': '初級',
        'zh': '初级',
        'vi': 'Cơ bản',
        'ar': 'مبتدئ',
        'th': 'ระดับเริ่มต้น',
      });

  String levelIntermediateTitle() => _t({
        'ko': '중급',
        'en': 'Intermediate',
        'es': 'Intermedio',
        'fr': 'Intermédiaire',
        'de': 'Mittel',
        'it': 'Intermedio',
        'nl': 'Gemiddeld',
        'da': 'Mellem',
        'nb': 'Middels',
        'ru': 'Средний',
        'pt': 'Intermediário',
        'ja': '中級',
        'zh': '中级',
        'vi': 'Trung cấp',
        'ar': 'متوسط',
        'th': 'ระดับกลาง',
      });

  String levelAdvancedTitle() => _t({
        'ko': '고급',
        'en': 'Advanced',
        'es': 'Avanzado',
        'fr': 'Avancé',
        'de': 'Fortgeschritten',
        'it': 'Avanzato',
        'nl': 'Gevorderd',
        'da': 'Avanceret',
        'nb': 'Avansert',
        'ru': 'Продвинутый',
        'pt': 'Avançado',
        'ja': '上級',
        'zh': '高级',
        'vi': 'Nâng cao',
        'ar': 'متقدم',
        'th': 'ขั้นสูง',
      });

  String levelBeginnerSub() => _t({
        'ko': '유산소 운동의 경험이 적어요',
        'en': 'I’m new to cardio',
        'es': 'Tengo poca experiencia',
        'fr': "J’ai peu d’expérience",
        'de': 'Wenig Erfahrung',
        'it': 'Poca esperienza',
        'nl': 'Weinig ervaring',
        'da': 'Lidt erfaring',
        'nb': 'Lite erfaring',
        'ru': 'Мало опыта',
        'pt': 'Pouca experiência',
        'ja': '経験が少ない',
        'zh': '经验较少',
        'vi': 'Ít kinh nghiệm',
        'ar': 'خبرة قليلة',
        'th': 'ประสบการณ์น้อย',
      });

  String levelIntermediateSub() => _t({
        'ko': '유산소 운동을 해봤고 체력이 좋아요',
        'en': 'I’ve done cardio and feel fit',
        'es': 'He hecho cardio y tengo buena forma',
        'fr': "J’ai déjà fait du cardio",
        'de': 'Schon Cardio gemacht',
        'it': 'Ho fatto cardio e sto bene',
        'nl': 'Ik heb cardio gedaan en ben fit',
        'da': 'Jeg har prøvet cardio',
        'nb': 'Jeg har prøvd cardio',
        'ru': 'Делал кардио, форма хорошая',
        'pt': 'Já fiz cardio e tenho bom preparo',
        'ja': '経験があって体力もある',
        'zh': '有经验且体能不错',
        'vi': 'Đã tập cardio và thể lực tốt',
        'ar': 'جربت الكارديو ولياقة جيدة',
        'th': 'เคยทำคาร์ดิโอและฟิตพอสมควร',
      });

  String levelAdvancedSub() => _t({
        'ko': '유산소 운동을 꾸준히 오래 해왔어요',
        'en': 'I’ve trained consistently for a long time',
        'es': 'He entrenado de forma constante',
        'fr': "Je m’entraîne régulièrement",
        'de': 'Trainiere schon lange',
        'it': 'Mi alleno con costanza da tempo',
        'nl': 'Ik train al lang consistent',
        'da': 'Jeg har trænet længe',
        'nb': 'Jeg har trent lenge',
        'ru': 'Давно тренируюсь регулярно',
        'pt': 'Treino de forma consistente há tempos',
        'ja': '継続的に長くやっている',
        'zh': '长期坚持训练',
        'vi': 'Tập đều đặn lâu dài',
        'ar': 'أتدرب بانتظام منذ مدة',
        'th': 'ออกกำลังกายสม่ำเสมอมานาน',
      });

  // ---- Screen 6 ----
  List<EmphasisTextSpan> s6TitleSpans() => _spans({
        'ko': const [
          EmphasisTextSpan('사용할 '),
          EmphasisTextSpan('단위', isRed: true),
          EmphasisTextSpan('를 선택해 주세요'),
        ],
        'en': const [
          EmphasisTextSpan('Choose your '),
          EmphasisTextSpan('units', isRed: true),
          EmphasisTextSpan(''),
        ],
      });

  String s6Helper() => _t({
        'ko': '설정에서 언제든지 변경할 수 있어요',
        'en': 'You can change this later in Settings.',
        'es': 'Puedes cambiarlo luego en Ajustes.',
        'fr': 'Modifiable plus tard dans Réglages.',
        'de': 'Später in den Einstellungen änderbar.',
        'it': 'Puoi cambiarlo più tardi nelle Impostazioni.',
        'nl': 'Je kunt dit later wijzigen in Instellingen.',
        'da': 'Du kan ændre det senere i Indstillinger.',
        'nb': 'Du kan endre dette senere i Innstillinger.',
        'ru': 'Можно изменить позже в настройках.',
        'pt': 'Você pode alterar depois em Ajustes.',
        'ja': '後で設定で変更できます',
        'zh': '可在设置中随时更改',
        'vi': 'Bạn có thể đổi sau trong Cài đặt.',
        'ar': 'يمكنك تغييره لاحقًا من الإعدادات.',
        'th': 'คุณเปลี่ยนได้ภายหลังในตั้งค่า',
      });

  // ---- Screen 7 ----
  List<EmphasisTextSpan> s7TitleSpans() => _spans({
        'ko': const [
          EmphasisTextSpan('이제 '),
          EmphasisTextSpan('시작', isRed: true),
          EmphasisTextSpan('하세요!'),
        ],
        'en': const [
          EmphasisTextSpan('Now '),
          EmphasisTextSpan('start', isRed: true),
          EmphasisTextSpan('!'),
        ],
      });

  // Subtitle is a rich text where a phrase is red.
  String s7SubtitleLine1() => _t({
        'ko': 'Valcue와 함께\n',
        'en': 'With Valcue,\n',
        'es': 'Con Valcue,\n',
        'fr': 'Avec Valcue,\n',
        'de': 'Mit Valcue,\n',
        'it': 'Con Valcue,\n',
        'nl': 'Met Valcue,\n',
        'da': 'Med Valcue,\n',
        'nb': 'Med Valcue,\n',
        'ru': 'С Valcue,\n',
        'pt': 'Com o Valcue,\n',
        'ja': 'Valcueと一緒に\n',
        'zh': '和 Valcue 一起\n',
        'vi': 'Cùng Valcue,\n',
        'ar': 'مع Valcue،\n',
        'th': 'ไปกับ Valcue\n',
      });

  String s7SubtitleRedPhrase() => _t({
        'ko': '효율적인 유산소',
        'en': 'efficient cardio',
        'es': 'cardio eficiente',
        'fr': 'cardio efficace',
        'de': 'effizientes Cardio',
        'it': 'cardio efficiente',
        'nl': 'efficiënte cardio',
        'da': 'effektiv cardio',
        'nb': 'effektiv cardio',
        'ru': 'эффективное кардио',
        'pt': 'cardio eficiente',
        'ja': '効率的な有酸素',
        'zh': '高效有氧',
        'vi': 'cardio hiệu quả',
        'ar': 'كارديو فعّال',
        'th': 'คาร์ดิโออย่างมีประสิทธิภาพ',
      });

  String s7SubtitleTail() => _t({
        'ko': '를 즐겨보세요',
        'en': ' and enjoy it.',
        'es': ' y disfrútalo.',
        'fr': ' et profite-en.',
        'de': ' und hab Spaß dabei.',
        'it': ' e goditelo.',
        'nl': ' en geniet ervan.',
        'da': ' og nyd det.',
        'nb': ' og nyt det.',
        'ru': ' и получай удовольствие.',
        'pt': ' e aproveite.',
        'ja': 'を楽しみましょう',
        'zh': '尽情享受吧',
        'vi': ' và tận hưởng nhé.',
        'ar': ' واستمتع به.',
        'th': 'แล้วสนุกไปด้วยกัน',
      });

  // ---- helpers ----
  String _t(Map<String, String> map) => map[code] ?? map['en'] ?? '';

  List<EmphasisTextSpan> _spans(
    Map<String, List<EmphasisTextSpan>> map,
  ) =>
      map[code] ?? map['en'] ?? const <EmphasisTextSpan>[];
}
