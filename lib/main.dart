import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:agrolink/config/firebase_options.dart';
import 'package:agrolink/config/router.dart';
import 'package:agrolink/core/theme/app_theme.dart';

/// ─────────────────────────────────────────────────────────────
/// AgroLink — Smart Agriculture Consultation Platform
/// ─────────────────────────────────────────────────────────────
/// 
/// Enterprise-grade agriculture management platform for
/// professional agronomists managing 700+ farm plots.
///
/// Features:
/// - Farmer & Plot Management
/// - Visit Planning & Tracking
/// - Route Optimization
/// - Disease Tracking & Analytics
/// - Offline-First Architecture
/// - Role-Based Access Control
/// ─────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: AgroLinkApp(),
    ),
  );
}

class AgroLinkApp extends ConsumerWidget {
  const AgroLinkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'AgroLink — Smart Agriculture Consultation',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Router
      routerConfig: router,
    );
  }
}
