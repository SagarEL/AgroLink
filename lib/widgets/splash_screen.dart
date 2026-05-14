import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primarySoft, AppColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x402E7D32),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.eco_outlined, color: Colors.white, size: 42),
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Agrolink',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Field intelligence for modern agronomy',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
              const SizedBox(height: AppSpacing.huge),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
