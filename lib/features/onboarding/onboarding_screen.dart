import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_routes.dart';
import '../../app/theme/design_tokens.dart';
import '../../core/widgets/primary_button.dart';

typedef _OnboardingPage = ({IconData icon, String title, String message});

const _pages = <_OnboardingPage>[
  (
    icon: Icons.psychology_outlined,
    title: 'Understand every scan',
    message:
        'ScanWise explains what a QR code or barcode contains before you '
        'decide what to do with it.',
  ),
  (
    icon: Icons.shield_outlined,
    title: 'Review before opening',
    message:
        'See the real destination and any structural warning signs before '
        'you open a link or share a code.',
  ),
  (
    icon: Icons.folder_outlined,
    title: 'Keep useful scans organized',
    message:
        'Save, search and organize the scans worth keeping in a private, '
        'searchable library.',
  ),
];

/// Three-page onboarding shown at the start of every launch. Completion is
/// not persisted yet, so onboarding reappears on the next cold start until a
/// persistence milestone adds a remembered preference.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  bool get _isLastPage => _currentPage == _pages.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLastPage) {
      context.go(AppRoutes.scan);
      return;
    }
    _pageController.nextPage(
      duration: AppMotion.stateTransition,
      curve: AppMotion.standardCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) =>
                    _OnboardingPageView(page: _pages[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                0,
                AppSpacing.screen,
                AppSpacing.section,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _pages.length; i++)
                        _PageDot(isActive: i == _currentPage),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.section),
                  if (_isLastPage) ...[
                    Text(
                      'Scan contents are processed on your device and are '
                      'not uploaded by ScanWise.',
                      textAlign: TextAlign.center,
                      style: AppTypography.supportingText.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.standard),
                  ],
                  PrimaryButton(
                    label: _isLastPage ? 'Start scanning' : 'Next',
                    onPressed: _next,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.section),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(page.icon, size: 44, color: colorScheme.primary),
                ),
                const SizedBox(height: AppSpacing.major),
                Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: AppTypography.screenTitle.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.tight),
                Text(
                  page.message,
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PageDot extends StatelessWidget {
  const _PageDot({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: AppMotion.stateTransition,
      curve: AppMotion.standardCurve,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.micro),
      width: isActive ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? colorScheme.primary : colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
    );
  }
}
