import 'package:flutter/material.dart';

import '../onboarding_strings.dart';
import '../widgets/onboarding_emphasis_text.dart';
import '../widgets/onboarding_theme.dart';

class OnboardingScreen2IntervalExplainer extends StatelessWidget {
  final int step; // 0..7 (0 = comparison, 1-7 = interval steps)

  const OnboardingScreen2IntervalExplainer({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    final s = OnboardingStrings.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Prevent layout "jumping" as steps add more text:
        // keep a stable content height, scroll only if truly needed.
        final contentHeight = constraints.maxHeight.clamp(520.0, 720.0);

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: SizedBox(
                height: contentHeight,
                // IMPORTANT: only animate when switching from comparison -> interval,
                // not for each step within the interval page (so the icon stays still).
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, anim) {
                    final fade = CurvedAnimation(
                      parent: anim,
                      curve: const Interval(0.0, 0.85, curve: Curves.easeOut),
                    );
                    final slide = Tween<Offset>(
                      begin: const Offset(0, 0.06),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                    );
                    return FadeTransition(
                      opacity: fade,
                      child: SlideTransition(position: slide, child: child),
                    );
                  },
                  child: step == 0
                      ? _ComparisonStep(strings: s, key: const ValueKey('cmp'))
                      : _IntervalsStep(
                          // Keep key stable so AnimatedSwitcher does NOT animate
                          // when step changes (icon stays fixed).
                          key: const ValueKey('intervals'),
                          strings: s,
                          step: step,
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ComparisonStep extends StatelessWidget {
  final OnboardingStrings strings;

  const _ComparisonStep({
    super.key,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardShadow = OnboardingTheme.mediumShadow;
    return Column(
      children: [
        const SizedBox(height: 30), // Adjusted spacing
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(OnboardingTheme.radiusLarge),
            boxShadow: [cardShadow],
            border: Border.all(
              color:
                  isDark ? OnboardingTheme.darkGrayFill : const Color(0xFFF0F0F0),
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              _CompareRow(
                icon: Icons.directions_walk,
                titleSpans: strings.ex2WalkTitleSpans(),
              ),
              const SizedBox(height: 16), // Reduced from 18
              Container(
                width: double.infinity,
                height: 0.8, // Slightly thinner divider
                color: isDark ? OnboardingTheme.darkGrayFill : const Color(0xFFF0F0F0),
              ),
              const SizedBox(height: 16), // Reduced from 18
              _CompareRow(
                icon: Icons.directions_run,
                titleSpans: strings.ex2RunTitleSpans(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          strings.ex2Question(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            color: theme.colorScheme.onSurface,
            height: 1.30,
          ),
        ),
      ],
    );
  }
}

class _CompareRow extends StatelessWidget {
  final IconData icon;
  final List<EmphasisTextSpan> titleSpans;

  const _CompareRow({
    required this.icon,
    required this.titleSpans,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 104, color: OnboardingTheme.primaryRed),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OnboardingRichTitle(spans: titleSpans),
        ),
      ],
    );
  }
}

class _IntervalsStep extends StatelessWidget {
  final OnboardingStrings strings;
  final int step; // 1..7

  const _IntervalsStep({
    super.key,
    required this.strings,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    // step mapping:
    // 1: line1
    // 2: line1+line2
    // 3: +line3
    // 4: +line4
    // 5: dots (appear one-by-one automatically)
    // 6: show "이렇게 30분씩,"
    // 7: show "이게 더 잘 빠집니다" (in addition to line 1)
    final showCount = step.clamp(1, 4);
    final lines = strings.ex2IntervalLines();

    return Column(
      children: [
        const SizedBox(height: 42),
        const Icon(Icons.directions_run,
            size: 116, color: OnboardingTheme.primaryRed),
        const SizedBox(height: 22),

        // Staggered reveal: each line animates in when it becomes visible.
        for (int i = 0; i < 4; i++) ...[
          _Reveal(
            visible: i < showCount,
            child: _Line(
              text: lines[i],
              highlightSpans: strings.ex2IntervalHighlightSpans(i),
            ),
          ),
          const SizedBox(height: 8),
        ],

        _Reveal(
          // Keep dots visible after they appear (do not disappear on next tap).
          visible: step >= 5,
          child: const _AnimatedDots(),
        ),
        const SizedBox(height: 14),
        _Reveal(
          visible: step >= 6,
          child: _Final(
            line1: strings.ex2FinalLine1Spans(),
            line2: strings.ex2FinalLine2Spans(),
            showSecondLine: step >= 7,
          ),
        ),
      ],
    );
  }
}

class _Reveal extends StatelessWidget {
  final bool visible;
  final Widget child;

  const _Reveal({
    required this.visible,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, anim) {
        final curved =
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        final fade = CurvedAnimation(
          parent: anim,
          curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
        );
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.22),
          end: Offset.zero,
        ).animate(curved);
        return SizeTransition(
          sizeFactor: curved,
          axisAlignment: -1.0, // grow from top, prevents icon movement
          child: FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          ),
        );
      },
      child: visible ? child : const SizedBox.shrink(),
    );
  }
}

class _Line extends StatelessWidget {
  final String text;
  final List<EmphasisTextSpan>? highlightSpans;

  const _Line({
    required this.text,
    required this.highlightSpans,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (highlightSpans == null) {
      return SizedBox(
        width: double.infinity,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
            color: theme.colorScheme.onSurface,
            height: 1.25,
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: OnboardingRichTitle(
        spans: highlightSpans!,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _Final extends StatelessWidget {
  final List<EmphasisTextSpan> line1;
  final List<EmphasisTextSpan> line2;
  final bool showSecondLine;

  const _Final({
    required this.line1,
    required this.line2,
    required this.showSecondLine,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OnboardingRichTitle(spans: line1),
        ),
        const SizedBox(height: 2),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 360),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, anim) {
            final curved =
                CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
            final fade = CurvedAnimation(
              parent: anim,
              curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
            );
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.18),
              end: Offset.zero,
            ).animate(curved);
            return FadeTransition(
              opacity: fade,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: showSecondLine
              ? SizedBox(
                  key: const ValueKey('final2'),
                  width: double.infinity,
                  child: OnboardingRichTitle(spans: line2),
                )
              : const SizedBox(key: ValueKey('empty')),
        ),
      ],
    );
  }
}

class _AnimatedDots extends StatefulWidget {
  const _AnimatedDots();

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a1;
  late final Animation<double> _a2;
  late final Animation<double> _a3;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _a1 = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
    );
    _a2 = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.25, 0.6, curve: Curves.easeOutCubic),
    );
    _a3 = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.5, 0.85, curve: Curves.easeOutCubic),
    );
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Dot(anim: _a1),
          const SizedBox(height: 2),
          _Dot(anim: _a2),
          const SizedBox(height: 2),
          _Dot(anim: _a3),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Animation<double> anim;
  const _Dot({required this.anim});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(anim),
        child: Text(
          '.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
