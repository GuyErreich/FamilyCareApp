import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _PickerSegment { month, year }

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

  var segment = _PickerSegment.month;
  var selectedMonth = initial.month;
  var selectedYear = initial.year.clamp(firstYear, lastYear);

  return showModalBottomSheet<DateTime>(
    context: context,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          final monthIndex = selectedMonth - 1;
          final yearIndex = years.indexOf(selectedYear);

          void applyAndClose() {
            Navigator.pop(sheetContext, DateTime(selectedYear, selectedMonth));
          }

          return SafeArea(
            child: SizedBox(
              height: 280,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Go to month',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        TextButton(
                          onPressed: applyAndClose,
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CupertinoSlidingSegmentedControl<_PickerSegment>(
                      groupValue: segment,
                      children: const {
                        _PickerSegment.month: Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text('Month'),
                        ),
                        _PickerSegment.year: Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text('Year'),
                        ),
                      },
                      onValueChanged: (value) {
                        if (value == null) return;
                        setState(() => segment = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: segment == _PickerSegment.month
                        ? CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem: monthIndex,
                            ),
                            itemExtent: 36,
                            onSelectedItemChanged: (index) {
                              setState(() => selectedMonth = index + 1);
                            },
                            children: List.generate(
                              12,
                              (index) => Center(
                                child: Text(
                                  DateFormat.MMMM()
                                      .format(DateTime(2000, index + 1)),
                                ),
                              ),
                            ),
                          )
                        : CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem: yearIndex < 0 ? 0 : yearIndex,
                            ),
                            itemExtent: 36,
                            onSelectedItemChanged: (index) {
                              setState(() => selectedYear = years[index]);
                            },
                            children: years
                                .map((y) => Center(child: Text('$y')))
                                .toList(),
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
