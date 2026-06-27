import 'package:family_care_scheduler/features/schedule/domain/schedule_timeline_item.dart';

/// Positioned timeline item for side-by-side overlap layout.
class PlacedTimelineItem {
  const PlacedTimelineItem({
    required this.item,
    required this.topMinutes,
    required this.heightMinutes,
    required this.columnIndex,
    required this.columnCount,
  });

  final ScheduleTimelineItem item;
  final double topMinutes;
  final double heightMinutes;
  final int columnIndex;
  final int columnCount;
}

/// Greedy column assignment for overlapping timeline items.
abstract final class TimelineLayoutEngine {
  static List<PlacedTimelineItem> layout(List<ScheduleTimelineItem> items) {
    if (items.isEmpty) return [];

    final indexed = List<ScheduleTimelineItem>.from(items)
      ..sort((a, b) => a.start.compareTo(b.start));

    final columnEnds = <DateTime>[];
    final columnByIndex = <int, int>{};

    for (var i = 0; i < indexed.length; i++) {
      final item = indexed[i];
      var column = 0;
      for (; column < columnEnds.length; column++) {
        if (!columnEnds[column].isAfter(item.start)) break;
      }
      if (column == columnEnds.length) {
        columnEnds.add(item.end);
      } else {
        columnEnds[column] = item.end;
      }
      columnByIndex[i] = column;
    }

    return [
      for (var i = 0; i < indexed.length; i++)
        _place(indexed, i, columnByIndex),
    ];
  }

  static PlacedTimelineItem _place(
    List<ScheduleTimelineItem> items,
    int index,
    Map<int, int> columnByIndex,
  ) {
    final item = items[index];
    final columnIndex = columnByIndex[index]!;
    var columnCount = columnIndex + 1;

    for (var j = 0; j < items.length; j++) {
      if (j == index) continue;
      if (!_overlaps(item, items[j])) continue;
      columnCount = columnCount > columnByIndex[j]! + 1
          ? columnCount
          : columnByIndex[j]! + 1;
    }

    final startMinutes = item.start.hour * 60 + item.start.minute +
        item.start.second / 60;
    final endMinutes =
        item.end.hour * 60 + item.end.minute + item.end.second / 60;
    final heightMinutes = (endMinutes - startMinutes).clamp(1.0, double.infinity);

    return PlacedTimelineItem(
      item: item,
      topMinutes: startMinutes,
      heightMinutes: heightMinutes,
      columnIndex: columnIndex,
      columnCount: columnCount,
    );
  }

  static bool _overlaps(ScheduleTimelineItem a, ScheduleTimelineItem b) {
    return a.start.isBefore(b.end) && a.end.isAfter(b.start);
  }
}
