import 'package:family_care_scheduler/core/theme/app_motion.dart';
import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_slot_selection.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_slot_actions_sheet.dart';
import 'package:flutter/material.dart';

export 'schedule_slot_actions_sheet.dart' show ScheduleSlotAction;

/// Deprecated inline confirm bar — prefer [showScheduleSlotActionsSheet].
@Deprecated('Use showScheduleSlotActionsSheet instead')
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
  late final AnimationController _enterController;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Material(
          elevation: 16,
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () {
                  showScheduleSlotActionsSheet(
                    context,
                    selection: widget.selection,
                    members: widget.members,
                    currentUserId: widget.currentUserId,
                    canManageOthers: widget.canManageOthers,
                    onConfirmShift: widget.onConfirmShift,
                    onConfirmUnavailable: widget.onConfirmUnavailable,
                  );
                },
                child: Text(
                  '${DateTimeUtils.formatDate(widget.selection.date)} · '
                  'Open actions',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
