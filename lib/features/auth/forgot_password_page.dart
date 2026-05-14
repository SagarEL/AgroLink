import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
import 'auth_controller.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).sendPasswordReset(_email.text);
    final s = ref.read(authControllerProvider);
    if (s.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.error.toString())));
    } else {
      setState(() => _sent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.huge),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_reset_rounded, size: 56, color: AppColors.primary),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    _sent ? 'Check your inbox' : 'Reset your password',
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _sent
                        ? "We've emailed a password reset link to ${_email.text}. The link expires in 1 hour."
                        : 'Enter the email associated with your Agrolink account. We’ll send you instructions to set a new password.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  if (!_sent) ...[
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.alternate_email_rounded),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      onPressed: state.isLoading ? null : _send,
                      child: state.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Send reset link'),
                    ),
                  ] else
                    FilledButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: const Text('Back to sign in'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
