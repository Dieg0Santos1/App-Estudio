import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../data/onboarding_repository.dart';
import 'focus_intro_animation.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  var _pageIndex = 0;

  static const _pages = [
    _OnboardingPageData(
      title: 'Convierte tu celular en una herramienta de estudio.',
      description: 'Bloquea distracciones y usa ese tiempo para aprender con intencion.',
      buttonLabel: 'Comenzar',
    ),
    _OnboardingPageData(
      title: 'Elige como quieres aprender.',
      description: 'Focus adapta cada sesion a tu estilo: visual, audio, escritura o mixto.',
      buttonLabel: 'Siguiente',
    ),
    _OnboardingPageData(
      title: 'Demuestra lo que aprendiste.',
      description: 'Al terminar, respondes preguntas breves para recuperar el acceso.',
      buttonLabel: 'Empezar',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_pageIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF061B38),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 700;
            final animationDimension = compact ? 126.0 : 220.0;
            final verticalPadding = compact ? 14.0 : 22.0;
            final copyHeight = compact ? 190.0 : 148.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, verticalPadding, 24, verticalPadding),
                  child: Column(
                    children: [
                      const _FocusWordmark(),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 360),
                        child: FocusIntroAnimation(
                          key: ValueKey(_pageIndex),
                          step: _pageIndex,
                          dimension: animationDimension,
                        ),
                      ),
                      SizedBox(height: compact ? 8 : 32),
                      SizedBox(
                        height: copyHeight,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _pages.length,
                          onPageChanged: (index) => setState(() => _pageIndex = index),
                          itemBuilder: (context, index) {
                            final item = _pages[index];
                            return _OnboardingCopy(data: item, compact: compact);
                          },
                        ),
                      ),
                      SizedBox(height: compact ? 8 : 22),
                      _PageIndicator(
                        count: _pages.length,
                        activeIndex: _pageIndex,
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: compact ? 52 : 56,
                        child: FilledButton(
                          onPressed: _handlePrimaryAction,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF22C7B8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          child: Text(page.buttonLabel),
                        ),
                      ),
                      SizedBox(height: compact ? 2 : 14),
                      TextButton(
                        onPressed: _goToAuth,
                        child: const Text(
                          'Ya tengo cuenta',
                          style: TextStyle(
                            color: Color(0xFF2DD4BF),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handlePrimaryAction() async {
    if (_pageIndex < _pages.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    await _finishOnboarding();
  }

  Future<void> _goToAuth() async {
    await _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    await ref.read(onboardingRepositoryProvider).markSeen();
    if (!mounted) {
      return;
    }

    context.go(AppRoute.auth.path);
  }
}

class _FocusWordmark extends StatelessWidget {
  const _FocusWordmark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Focus',
          style: TextStyle(
            color: Color(0xFFEFF6FF),
            fontSize: 24,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF143A52),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF22C7B8).withValues(alpha: 0.4)),
          ),
          child: const Text(
            'AI',
            style: TextStyle(
              color: Color(0xFF5EEAD4),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingCopy extends StatelessWidget {
  const _OnboardingCopy({
    required this.data,
    required this.compact,
  });

  final _OnboardingPageData data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          data.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFF8FAFC),
            fontSize: 24,
            fontWeight: FontWeight.w900,
            height: 1.14,
          ),
        ),
        SizedBox(height: compact ? 9 : 14),
        Text(
          data.description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFB7C6D8),
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.count,
    required this.activeIndex,
  });

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          width: isActive ? 24 : 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2DD4BF) : const Color(0xFF2F5570),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.buttonLabel,
  });

  final String title;
  final String description;
  final String buttonLabel;
}
