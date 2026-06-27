import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/family/domain/family_member_role.dart';

/// Who to contact when a companion drops a shift.
class CoverageFallbackPlan {
  const CoverageFallbackPlan({
    required this.primaryUserId,
    required this.backupUserIds,
  });

  /// First person who should try to cover the shift.
  final String? primaryUserId;

  /// Other companions on the backup list, in priority order.
  final List<String> backupUserIds;
}

/// Resolves fallback coverage from a family backup chain.
abstract final class CoverageFallbackResolver {
  /// Ordered assignable ids after [droppedUserId] is removed from consideration.
  static CoverageFallbackPlan plan({
    required List<String> chainUserIds,
    required String droppedUserId,
  }) {
    final withoutDropped =
        chainUserIds.where((id) => id != droppedUserId).toList();
    if (withoutDropped.isEmpty) {
      return const CoverageFallbackPlan(
        primaryUserId: null,
        backupUserIds: [],
      );
    }

    final dropIndex = chainUserIds.indexOf(droppedUserId);
    if (dropIndex == -1) {
      return CoverageFallbackPlan(
        primaryUserId: withoutDropped.first,
        backupUserIds: withoutDropped.skip(1).toList(),
      );
    }

    final afterDrop = chainUserIds
        .skip(dropIndex + 1)
        .where((id) => id != droppedUserId)
        .toList();
    if (afterDrop.isNotEmpty) {
      return CoverageFallbackPlan(
        primaryUserId: afterDrop.first,
        backupUserIds: afterDrop.skip(1).toList(),
      );
    }

    final beforeDrop = chainUserIds
        .take(dropIndex)
        .where((id) => id != droppedUserId)
        .toList();
    if (beforeDrop.isEmpty) {
      return const CoverageFallbackPlan(
        primaryUserId: null,
        backupUserIds: [],
      );
    }

    return CoverageFallbackPlan(
      primaryUserId: beforeDrop.first,
      backupUserIds: beforeDrop.skip(1).toList(),
    );
  }

  /// Default chain from current family members when none is configured.
  static List<String> defaultChain(List<FamilyMember> members) {
    final sorted = [...members]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return sorted.map(FamilyMemberRole.assignableId).toList();
  }

  /// Maps stored assignable ids to members still in the family.
  static List<FamilyMember> orderedMembers({
    required List<String> chainUserIds,
    required List<FamilyMember> members,
  }) {
    final byId = {
      for (final member in members)
        FamilyMemberRole.assignableId(member): member,
    };
    final ordered = <FamilyMember>[];
    final seenMemberIds = <String>{};

    for (final id in chainUserIds) {
      final member = byId[id];
      if (member != null) {
        ordered.add(member);
        seenMemberIds.add(member.id);
      }
    }

    final remaining = members.where((m) => !seenMemberIds.contains(m.id)).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    ordered.addAll(remaining);
    return ordered;
  }
}
