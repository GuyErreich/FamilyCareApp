import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Bottom sheet to jump the calendar to a specific month and year.
Future<DateTime?> showScheduleMonthYearPicker(
  BuildContext context, {
  required DateTime initial,
}) {
  final now = DateTime.now();
  final firstYear = now.year - 2;
  final lastYear = now.year + 2;
  final years = List.generate(
    lastYear - firstYear + 1,
    (index) => firstYear + index,
  );

  var selectedMonth = initial.month;
  var selectedYear = initial.year.clamp(firstYear, lastYear);

  return showModalBottomSheet<DateTime>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          final scheme = Theme.of(context).colorScheme;

          void applyAndClose() {
            Navigator.pop(sheetContext, DateTime(selectedYear, selectedMonth));
          }

          return SafeArea(
            child: SizedBox(
              height: 248,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: Text(
                      'Go to month',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: years.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final year = years[index];
                        final selected = year == selectedYear;
                        return ChoiceChip(
                          label: Text('$year'),
                          selected: selected,
                          onSelected: (_) {
                            setState(() => selectedYear = year);
                          },
                          visualDensity: VisualDensity.compact,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 12,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final month = index + 1;
                        final label =
                            DateFormat.MMM().format(DateTime(2000, month));
                        final selected = month == selectedMonth;
                        return ActionChip(
                          label: Text(label),
                          backgroundColor: selected
                              ? scheme.primaryContainer
                              : scheme.surfaceContainerHigh,
                          labelStyle: TextStyle(
                            color: selected
                                ? scheme.onPrimaryContainer
                                : scheme.onSurface,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          onPressed: () {
                            setState(() => selectedMonth = month);
                            applyAndClose();
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: FilledButton(
                      onPressed: applyAndClose,
                      child: const Text('Go'),
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
