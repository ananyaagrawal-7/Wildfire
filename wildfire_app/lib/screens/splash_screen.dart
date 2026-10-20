import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/preferences_service.dart';
import '../state/app_state.dart';
import '../widgets/app_logo.dart';
import 'onboarding_screen.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  final AppState appState;

  const SplashScreen({super.key, required this.appState});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  double _loadingProgress = 0.05;
  String _currentLoadingStage = 'Initializing Indian Forest GIS Telemetry...';
  Timer? _stageTimer;

  final List<_LoadingStep> _stages = const [
    _LoadingStep(
      progress: 0.22,
      stage: 'Connecting to Open-Meteo India Telemetry Grid...',
    ),
    _LoadingStep(
      progress: 0.48,
      stage: 'Syncing NASA FIRMS South Asia Satellite Detections...',
    ),
    _LoadingStep(
      progress: 0.74,
      stage: 'Calibrating Random Forest Fire Weather Index (FWI)...',
    ),
    _LoadingStep(
      progress: 0.92,
      stage: 'Loading Uttarakhand, Simlipal & Bandipur Belts...',
    ),
    _LoadingStep(
      progress: 1.00,
      stage: 'Ready • Monitoring Active Indian Forest Belts',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _startLoadingSequence();
  }

  void _startLoadingSequence() {
    int stepIndex = 0;
    _stageTimer = Timer.periodic(const Duration(milliseconds: 550), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (stepIndex < _stages.length) {
        setState(() {
          _loadingProgress = _stages[stepIndex].progress;
          _currentLoadingStage = _stages[stepIndex].stage;
        });
        stepIndex++;
      } else {
        timer.cancel();
        _navigateToNext();
      }
    });
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final onboardingDone = await PreferencesService.isOnboardingCompleted();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => onboardingDone
            ? MainNavigationScreen(appState: widget.appState)
            : OnboardingScreen(appState: widget.appState),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _stageTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Animated Armored Shield Logo with Glowing Fire & Pine Emblem
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: const AppLogo(
                      size: 135,
                      showBadge: true,
                      showAura: true,
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Brand Title with India Identifier
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'WildFire',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'AI',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: AppColors.background,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // India-Specific Mission Tagline
              const Text(
                'India Forest Fire Early-Warning & Detection',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 14),

              // B.Tech Capstone & Forest Survey Citation Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderHighlight, width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school_rounded, color: AppColors.primary, size: 15),
                    SizedBox(width: 6),
                    Text(
                      'B.Tech Data Science • Capstone Prototype',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Dynamic Multi-Stage Loader Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.0),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                backgroundColor: AppColors.surfaceElevated,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'TELEMETRY SYNC',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${(_loadingProgress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: _loadingProgress),
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) {
                          return LinearProgressIndicator(
                            value: value,
                            minHeight: 6,
                            backgroundColor: AppColors.surfaceElevated,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Current Stage Status Text
                    Text(
                      _currentLoadingStage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingStep {
  final double progress;
  final String stage;

  const _LoadingStep({
    required this.progress,
    required this.stage,
  });
}
