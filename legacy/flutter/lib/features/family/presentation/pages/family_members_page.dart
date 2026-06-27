import 'package:family_care_scheduler/core/providers/repository_providers.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/family/domain/family_member_role.dart';
import 'package:family_care_scheduler/features/family/presentation/providers/family_providers.dart';
import 'package:family_care_scheduler/shared/widgets/app_card.dart';
import 'package:family_care_scheduler/shared/widgets/app_scaffold.dart';
import 'package:family_care_scheduler/shared/widgets/member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class FamilyMembersPage extends ConsumerStatefulWidget {
  const FamilyMembersPage({super.key});

  @override
  ConsumerState<FamilyMembersPage> createState() => _FamilyMembersPageState();
}

class _FamilyMembersPageState extends ConsumerState<FamilyMembersPage> {
  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(familyMembersProvider);
    final canManageRoles = ref.watch(canManageMemberRolesProvider);
    final currentUser = ref.watch(authStateProvider).valueOrNull;

    return AppScaffold(
      title: 'Family',
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.person_add),
      ),
      body: membersAsync.when(
        data: (members) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: members.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final member = members[index];
            return AppCard(
              onTap: () => _showEditDialog(
                context,
                member,
                canManageRoles: canManageRoles,
                currentUserId: currentUser?.id,
              ),
              child: ListTile(
                leading: MemberAvatar(member: member),
                title: Text(member.name),
                subtitle: Text(
                  [
                    FamilyMemberRole.label(member.role),
                    if (member.phone != null) member.phone!,
                  ].join(' · '),
                ),
                trailing: Icon(
                  Icons.circle,
                  color: _colorFromHex(member.colorHex),
                  size: 16,
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user?.familyId == null) return;

    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    var colorHex = '#4A6741';

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add family member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (saved != true || nameController.text.trim().isEmpty) return;

    final member = FamilyMember(
      id: const Uuid().v4(),
      familyId: user!.familyId!,
      name: nameController.text.trim(),
      phone: phoneController.text.trim().isEmpty
          ? null
          : phoneController.text.trim(),
      colorHex: colorHex,
      createdAt: DateTime.now(),
    );

    await ref.read(familyRepositoryProvider).addMember(member);
  }

  Future<void> _showEditDialog(
    BuildContext context,
    FamilyMember member, {
    required bool canManageRoles,
    required String? currentUserId,
  }) async {
    final nameController = TextEditingController(text: member.name);
    final phoneController = TextEditingController(text: member.phone ?? '');
    var role = member.role;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              if (canManageRoles &&
                  member.role != FamilyMemberRole.owner &&
                  member.userId != currentUserId) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: FamilyMemberRole.assignableRoles
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(FamilyMemberRole.label(value)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setDialogState(() => role = value);
                  },
                ),
              ] else if (member.role != FamilyMemberRole.member) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Role: ${FamilyMemberRole.label(member.role)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (saved != true) return;

    await ref.read(familyRepositoryProvider).updateMember(
          member.copyWith(
            name: nameController.text.trim(),
            phone: phoneController.text.trim().isEmpty
                ? null
                : phoneController.text.trim(),
            role: canManageRoles &&
                    member.role != FamilyMemberRole.owner &&
                    member.userId != currentUserId
                ? role
                : member.role,
          ),
        );
  }

  Color _colorFromHex(String hex) {
    final value = int.parse(hex.replaceFirst('#', ''), radix: 16);
    return Color(0xFF000000 | value);
  }
}
