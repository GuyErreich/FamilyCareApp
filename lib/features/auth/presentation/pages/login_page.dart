import 'package:family_care_scheduler/core/constants/app_constants.dart';
import 'package:family_care_scheduler/core/extensions/build_context_extensions.dart';
import 'package:family_care_scheduler/core/providers/repository_providers.dart';
import 'package:family_care_scheduler/core/router/app_routes.dart';
import 'package:family_care_scheduler/shared/widgets/app_scaffold.dart';
import 'package:family_care_scheduler/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInEmail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await ref.read(authRepositoryProvider).signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;
    result.when(
      success: (_) => context.go(AppRoutes.dashboard),
      failure: (f) => setState(() {
        _error = f.message;
        _isLoading = false;
      }),
    );
  }

  Future<void> _signInGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await ref.read(authRepositoryProvider).signInWithGoogle();
    if (!mounted) return;
    result.when(
      success: (_) => context.go(AppRoutes.dashboard),
      failure: (f) => setState(() {
        _error = f.message;
        _isLoading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppConstants.appName,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Welcome back', style: context.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Sign in to coordinate companion shifts.',
              style: context.textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: context.colorScheme.error)),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Sign in',
              icon: Icons.login,
              isLoading: _isLoading,
              onPressed: _signInEmail,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _signInGoogle,
              icon: const Icon(Icons.g_mobiledata),
              label: const Text('Continue with Google'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.push(AppRoutes.register),
              child: const Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}
