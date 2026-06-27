import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_constants.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_slot_selection.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_shift_conflict.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ScheduleQuickAddResult {
  placeOnCalendar,
  continueToCreate,
}

class ScheduleQuickAddSelection {
  const ScheduleQuickAddSelection({
    required this.selection,
    required this.action,
  });

  final ScheduleSlotSelection selection;
  final ScheduleQuickAddResult action;
}

/// Quick-add sheet: pick date, time, then place on grid or continue to create shift.
Future<ScheduleQuickAddSelection?> showScheduleQuickAddSheet(
  BuildContext context, {
  DateTime? initialDate,
  bool allowPlaceOnCalendar = true,
  List<Shift> existingShifts = const [],
}) {
  final today = DateTimeUtils.dateOnly(DateTime.now());
  final dates = List.generate(30, (i) => today.add(Duration(days: i)));
  final initial = initialDate ?? today;
  var dateIndex = dates.indexWhere(
    (d) => DateTimeUtils.dateOnly(d) == DateTimeUtils.dateOnly(initial),
  );
  if (dateIndex < 0) dateIndex = 0;

  const slotMinutes = 30;
  final timeSlots = <TimeOfDay>[
    for (var h = 0; h < 24; h++)
      for (var m = 0; m < 60; m += slotMinutes)
        TimeOfDay(hour: h, minute: m),
  ];
  var timeIndex = 18; // 09:00 default

  return showModalBottomSheet<ScheduleQuickAddSelection>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          ScheduleSlotSelection buildSelection() {
            final date = dates[dateIndex];
            final time = timeSlots[timeIndex];
            return ScheduleSlotSelection(
              date: date,
              start: time,
              durationMinutes: ScheduleConstants.defaultDurationMinutes,
            );
          }

          final selection = buildSelection();
          final hasConflict = ScheduleShiftConflict.hasOverlap(
            selection: selection,
            shifts: existingShifts,
          );
          final scheme = Theme.of(context).colorScheme;

          return SafeArea(
            child: SizedBox(
              height: hasConflict ? 400 : 360,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: Text(
                      'Add shift',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  if (hasConflict)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Material(
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
                                    selection: selection,
                                    shifts: existingShifts,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: scheme.onErrorContainer,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem: dateIndex,
                            ),
                            itemExtent: 36,
                            onSelectedItemChanged: (index) {
                              setState(() => dateIndex = index);
                            },
                            children: dates
                                .map(
                                  (d) => Center(
                                    child: Text(DateTimeUtils.formatDate(d)),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem: timeIndex,
                            ),
                            itemExtent: 36,
                            onSelectedItemChanged: (index) {
                              setState(() => timeIndex = index);
                            },
                            children: timeSlots
                                .map(
                                  (t) => Center(
                                    child: Text(
                                      DateTimeUtils.formatTimeOfDay(t),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      children: [
                        if (allowPlaceOnCalendar) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: hasConflict
                                  ? null
                                  : () => Navigator.pop(
                                        sheetContext,
                                        ScheduleQuickAddSelection(
                                          selection: selection,
                                          action: ScheduleQuickAddResult
                                              .placeOnCalendar,
                                        ),
                                      ),
                              child: const Text('Place'),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: FilledButton(
                            onPressed: hasConflict
                                ? null
                                : () => Navigator.pop(
                                      sheetContext,
                                      ScheduleQuickAddSelection(
                                        selection: selection,
                                        action: ScheduleQuickAddResult
                                            .continueToCreate,
                                      ),
                                    ),
                            child: const Text('Continue'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
