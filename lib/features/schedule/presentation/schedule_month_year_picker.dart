import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Dialog to jump the calendar to a specific month and year.
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

  return showDialog<DateTime>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Go to month'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  value: selectedMonth,
                  decoration: const InputDecoration(labelText: 'Month'),
                  items: List.generate(12, (index) {
                    final month = index + 1;
                    final label = DateFormat.MMMM().format(DateTime(2000, month));
                    return DropdownMenuItem(value: month, child: Text(label));
                  }),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => selectedMonth = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  value: selectedYear,
                  decoration: const InputDecoration(labelText: 'Year'),
                  items: years
                      .map(
                        (year) => DropdownMenuItem(
                          value: year,
                          child: Text('$year'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => selectedYear = value);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(
                  dialogContext,
                  DateTime(selectedYear, selectedMonth),
                ),
                child: const Text('Go'),
              ),
            ],
          );
        },
      );
    },
  );
}
