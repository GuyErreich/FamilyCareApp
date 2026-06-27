import 'package:family_care_scheduler/core/extensions/build_context_extensions.dart';
import 'package:family_care_scheduler/core/providers/repository_providers.dart';
import 'package:family_care_scheduler/core/router/app_routes.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:family_care_scheduler/shared/widgets/app_scaffold.dart';
import 'package:family_care_scheduler/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _familyNameController = TextEditingController();
  final _grandpaNameController = TextEditingController(text: 'Grandpa');
  final _inviteCodeController = TextEditingController();
  var _isLoading = false;
  String? _error;
  var _joinMode = false;

  @override
  void dispose() {
    _familyNameController.dispose();
    _grandpaNameController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _createFamily() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await ref.read(familyRepositoryProvider).createFamily(
          name: _familyNameController.text.trim(),
          grandpaName: _grandpaNameController.text.trim(),
          ownerUserId: user.id,
        );

    if (!mounted) return;
    result.when(
      success: (_) {
        ref.invalidate(authStateProvider);
        context.go(AppRoutes.dashboard);
      },
      failure: (f) => setState(() {
        _error = f.message;
        _isLoading = false;
      }),
    );
  }

  Future<void> _joinFamily() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await ref.read(familyRepositoryProvider).joinFamily(
          inviteCode: _inviteCodeController.text.trim().toUpperCase(),
          userId: user.id,
        );

    if (!mounted) return;
    result.when(
      success: (_) {
        ref.invalidate(authStateProvider);
        context.go(AppRoutes.dashboard);
      },
      failure: (f) => setState(() {
        _error = f.message;
        _isLoading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Join your family',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Create family')),
                ButtonSegment(value: true, label: Text('Join with code')),
              ],
              selected: {_joinMode},
              onSelectionChanged: (value) =>
                  setState(() => _joinMode = value.first),
            ),
            const SizedBox(height: 24),
            if (!_joinMode) ...[
              TextField(
                controller: _familyNameController,
                decoration: const InputDecoration(labelText: 'Family name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _grandpaNameController,
                decoration: const InputDecoration(
                  labelText: 'Who are we caring for?',
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Create family',
                isLoading: _isLoading,
                onPressed: _createFamily,
              ),
            ] else ...[
              TextField(
                controller: _inviteCodeController,
                decoration: const InputDecoration(labelText: 'Invite code'),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Join family',
                isLoading: _isLoading,
                onPressed: _joinFamily,
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: context.colorScheme.error)),
            ],
          ],
        ),
      ),
    );
  }
}
