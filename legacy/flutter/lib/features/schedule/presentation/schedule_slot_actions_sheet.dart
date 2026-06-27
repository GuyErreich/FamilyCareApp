import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/family/domain/family_member_role.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_slot_selection.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_shift_conflict.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:flutter/material.dart';

/// What to create from a selected timeline slot.
enum ScheduleSlotAction { shift, unavailable }

/// Bottom sheet to confirm a timeline slot assignment or unavailability.
Future<void> showScheduleSlotActionsSheet(
  BuildContext context, {
  required ScheduleSlotSelection selection,
  required List<FamilyMember> members,
  required String currentUserId,
  required bool canManageOthers,
  required void Function(String assigneeId) onConfirmShift,
  Future<void> Function(String userId)? onConfirmUnavailable,
  List<Shift> existingShifts = const [],
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => _ScheduleSlotActionsSheet(
      selection: selection,
      members: members,
      currentUserId: currentUserId,
      canManageOthers: canManageOthers,
      onConfirmShift: onConfirmShift,
      onConfirmUnavailable: onConfirmUnavailable,
      existingShifts: existingShifts,
      onClose: () => Navigator.pop(sheetContext),
    ),
  );
}

class _ScheduleSlotActionsSheet extends StatefulWidget {
  const _ScheduleSlotActionsSheet({
    required this.selection,
    required this.members,
    required this.currentUserId,
    required this.canManageOthers,
    required this.onConfirmShift,
    required this.onConfirmUnavailable,
    required this.existingShifts,
    required this.onClose,
  });

  final ScheduleSlotSelection selection;
  final List<FamilyMember> members;
  final String currentUserId;
  final bool canManageOthers;
  final void Function(String assigneeId) onConfirmShift;
  final Future<void> Function(String userId)? onConfirmUnavailable;
  final List<Shift> existingShifts;
  final VoidCallback onClose;

  @override
  State<_ScheduleSlotActionsSheet> createState() =>
      _ScheduleSlotActionsSheetState();
}

class _ScheduleSlotActionsSheetState extends State<_ScheduleSlotActionsSheet> {
  late String _assigneeId;
  var _action = ScheduleSlotAction.shift;
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    _assigneeId = widget.currentUserId;
  }

  bool _assigneeStillValid() {
    if (!widget.canManageOthers) {
      return _assigneeId == widget.currentUserId;
    }
    return widget.members.any(
      (member) => FamilyMemberRole.assignableId(member) == _assigneeId,
    );
  }

  Future<void> _submit() async {
    if (_action == ScheduleSlotAction.shift) {
      widget.onClose();
      widget.onConfirmShift(_assigneeId);
      return;
    }

    final save = widget.onConfirmUnavailable;
    if (save == null) return;

    setState(() => _isSaving = true);
    await save(_assigneeId);
    if (mounted) {
      setState(() => _isSaving = false);
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isShift = _action == ScheduleSlotAction.shift;
    final title = isShift
        ? (widget.canManageOthers ? 'Assign companion' : 'Assign yourself')
        : (widget.canManageOthers
            ? 'Mark unavailable'
            : 'Mark yourself unavailable');

    if (!_assigneeStillValid()) {
      _assigneeId = widget.currentUserId;
    }

    final shiftConflict = isShift &&
        ScheduleShiftConflict.hasOverlap(
          selection: widget.selection,
          shifts: widget.existingShifts,
        );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              '${DateTimeUtils.formatDate(widget.selection.date)} · '
              '${DateTimeUtils.formatTimeRange(widget.selection.startDateTime, widget.selection.endDateTime)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            if (shiftConflict) ...[
              const SizedBox(height: 12),
              Material(
                color: scheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: scheme.onErrorContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ScheduleShiftConflict.message(
                            selection: widget.selection,
                            shifts: widget.existingShifts,
                          ),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.onErrorContainer,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            SegmentedButton<ScheduleSlotAction>(
              segments: const [
                ButtonSegment(
                  value: ScheduleSlotAction.shift,
                  label: Text('Shift'),
                  icon: Icon(Icons.event, size: 18),
                ),
                ButtonSegment(
                  value: ScheduleSlotAction.unavailable,
                  label: Text('Unavailable'),
                  icon: Icon(Icons.event_busy, size: 18),
                ),
              ],
              selected: {_action},
              onSelectionChanged: (values) {
                setState(() => _action = values.first);
              },
            ),
            if (widget.canManageOthers && widget.members.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _assigneeId,
                decoration: InputDecoration(
                  labelText: isShift ? 'Companion' : 'Who',
                  isDense: true,
                ),
                items: widget.members
                    .map(
                      (member) => DropdownMenuItem(
                        value: FamilyMemberRole.assignableId(member),
                        child: Text(member.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _assigneeId = value);
                },
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onClose,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: _isSaving || shiftConflict ? null : _submit,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isShift ? 'Continue' : 'Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
