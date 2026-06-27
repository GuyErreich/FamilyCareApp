import 'package:family_care_scheduler/core/theme/app_motion.dart';
import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/family/domain/family_member_role.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_slot_selection.dart';
import 'package:flutter/material.dart';

/// What to create from a selected timeline slot.
enum ScheduleSlotAction { shift, unavailable }

/// Bottom bar to confirm a timeline slot assignment or unavailability.
class ScheduleSlotConfirmBar extends StatefulWidget {
  const ScheduleSlotConfirmBar({
    required this.selection,
    required this.members,
    required this.currentUserId,
    required this.canManageOthers,
    required this.onConfirmShift,
    this.onConfirmUnavailable,
    required this.onClear,
    super.key,
  });

  final ScheduleSlotSelection selection;
  final List<FamilyMember> members;
  final String currentUserId;
  final bool canManageOthers;
  final void Function(String assigneeId) onConfirmShift;
  final Future<void> Function(String userId)? onConfirmUnavailable;
  final VoidCallback onClear;

  @override
  State<ScheduleSlotConfirmBar> createState() => _ScheduleSlotConfirmBarState();
}

class _ScheduleSlotConfirmBarState extends State<ScheduleSlotConfirmBar>
    with SingleTickerProviderStateMixin {
  late String _assigneeId;
  var _action = ScheduleSlotAction.shift;
  var _isSaving = false;
  late final AnimationController _enterController;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _assigneeId = _defaultAssigneeId();
    _enterController = AnimationController(
      vsync: this,
      duration: AppMotion.medium,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _enterController,
      curve: AppMotion.spring,
    ));
    _fade = CurvedAnimation(
      parent: _enterController,
      curve: AppMotion.enter,
    );
    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ScheduleSlotConfirmBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_assigneeStillValid()) {
      _assigneeId = _defaultAssigneeId();
    }
  }

  String _defaultAssigneeId() => widget.currentUserId;

  bool _assigneeStillValid() {
    if (!widget.canManageOthers) return _assigneeId == widget.currentUserId;
    return widget.members.any(
      (member) => FamilyMemberRole.assignableId(member) == _assigneeId,
    );
  }

  Future<void> _submit() async {
    if (_action == ScheduleSlotAction.shift) {
      widget.onConfirmShift(_assigneeId);
      return;
    }

    final save = widget.onConfirmUnavailable;
    if (save == null) return;

    setState(() => _isSaving = true);
    await save(_assigneeId);
    if (mounted) setState(() => _isSaving = false);
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

    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Material(
          elevation: 16,
          shadowColor: scheme.shadow.withValues(alpha: 0.25),
          color: scheme.surfaceContainerHigh,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                        const SizedBox(height: 10),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          '${DateTimeUtils.formatDate(widget.selection.date)} · '
                          '${DateTimeUtils.formatTimeRange(widget.selection.startDateTime, widget.selection.endDateTime)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                        if (isShift &&
                            widget.canManageOthers &&
                            widget.members.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: _assigneeId,
                            decoration: const InputDecoration(
                              labelText: 'Companion',
                              isDense: true,
                            ),
                            items: widget.members
                                .map(
                                  (member) => DropdownMenuItem(
                                    value:
                                        FamilyMemberRole.assignableId(member),
                                    child: Text(member.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _assigneeId = value);
                            },
                          ),
                        ] else if (!isShift &&
                            widget.canManageOthers &&
                            widget.members.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: _assigneeId,
                            decoration: const InputDecoration(
                              labelText: 'Who',
                              isDense: true,
                            ),
                            items: widget.members
                                .map(
                                  (member) => DropdownMenuItem(
                                    value:
                                        FamilyMemberRole.assignableId(member),
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
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onClear,
                    child: const Text('Clear'),
                  ),
                  FilledButton(
                    onPressed: _isSaving ? null : _submit,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isShift ? 'Continue' : 'Save'),
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
