import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/core/providers/repository_providers.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/family/domain/family_member_role.dart';
import 'package:family_care_scheduler/features/family/presentation/providers/family_providers.dart';
import 'package:family_care_scheduler/features/settings/domain/entities/family_settings.dart';
import 'package:family_care_scheduler/features/settings/domain/usecases/coverage_fallback_resolver.dart';
import 'package:family_care_scheduler/features/settings/presentation/providers/family_settings_provider.dart';
import 'package:family_care_scheduler/shared/widgets/app_scaffold.dart';
import 'package:family_care_scheduler/shared/widgets/member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configure who covers a shift when someone drops out last-minute.
class CoverageFallbackPage extends ConsumerStatefulWidget {
  const CoverageFallbackPage({super.key});

  @override
  ConsumerState<CoverageFallbackPage> createState() =>
      _CoverageFallbackPageState();
}

class _CoverageFallbackPageState extends ConsumerState<CoverageFallbackPage> {
  List<FamilyMember> _orderedMembers = [];
  var _dirty = false;
  var _isSaving = false;

  void _ensureDraft(List<FamilyMember> members, FamilySettings? settings) {
    if (_dirty || members.isEmpty || _orderedMembers.isNotEmpty) return;
    final chain = settings?.coverageFallbackUserIds ?? [];
    _orderedMembers = CoverageFallbackResolver.orderedMembers(
      chainUserIds:
          chain.isEmpty ? CoverageFallbackResolver.defaultChain(members) : chain,
      members: members,
    );
  }

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(familyMembersProvider).valueOrNull ?? [];
    final settings = ref.watch(familySettingsProvider).valueOrNull;
    final canEdit = ref.watch(canManageFamilyShiftsProvider);
    final scheme = Theme.of(context).colorScheme;

    _ensureDraft(members, settings);

    return AppScaffold(
      title: 'Coverage fallback',
      showBackButton: true,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'When a companion can\'t make a shift, the app follows this order '
            'and notifies everyone on the list.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          if (!canEdit)
            Card(
              color: scheme.surfaceContainerHighest,
              child: const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('View only'),
                subtitle: Text(
                  'Only owners and managers can change the backup order.',
                ),
              ),
            ),
          if (_orderedMembers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text('Add family members to set a backup plan.')),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: canEdit,
              itemCount: _orderedMembers.length,
              onReorder: canEdit ? _onReorder : (_, _) {},
              itemBuilder: (context, index) {
                final member = _orderedMembers[index];
                final isFirst = index == 0;
                return Card(
                  key: ValueKey(member.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: MemberAvatar(member: member),
                    title: Text(member.name),
                    subtitle: Text(
                      isFirst
                          ? 'First backup when someone drops out'
                          : 'Backup #${index + 1}',
                    ),
                    trailing: canEdit
                        ? ReorderableDragStartListener(
                            index: index,
                            child: const Icon(Icons.drag_handle),
                          )
                        : null,
                  ),
                );
              },
            ),
          if (canEdit && _orderedMembers.isNotEmpty) ...[
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Save backup order'),
            ),
          ],
        ],
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      _dirty = true;
      if (newIndex > oldIndex) newIndex -= 1;
      final member = _orderedMembers.removeAt(oldIndex);
      _orderedMembers.insert(newIndex, member);
    });
  }

  Future<void> _save() async {
    final user = ref.read(authStateProvider).valueOrNull;
    final familyId = user?.familyId;
    if (familyId == null) return;

    setState(() => _isSaving = true);

    final settings = FamilySettings(
      familyId: familyId,
      coverageFallbackUserIds: _orderedMembers
          .map(FamilyMemberRole.assignableId)
          .toList(),
      updatedAt: DateTime.now(),
    );

    final result = await ref
        .read(familySettingsRepositoryProvider)
        .saveFamilySettings(settings);

    if (!mounted) return;
    setState(() => _isSaving = false);

    switch (result) {
      case Success():
        setState(() => _dirty = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coverage fallback order saved')),
        );
      case Error(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }
}
