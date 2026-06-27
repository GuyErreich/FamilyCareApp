import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_constants.dart';
import 'package:family_care_scheduler/features/schedule/presentation/planner_slot_geometry.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_calendar_style.dart';
import 'package:flutter/material.dart';

/// Hour-band backgrounds and column edge for planner day columns.
class PlannerDaySlotBackgroundPainter extends CustomPainter {
  const PlannerDaySlotBackgroundPainter({
    required this.scheme,
    required this.day,
    required this.isToday,
    required this.heightPerMinute,
  });

  final ColorScheme scheme;
  final DateTime day;
  final bool isToday;
  final double heightPerMinute;

  @override
  void paint(Canvas canvas, Size size) {
    final columnPaint = Paint()
      ..color = ScheduleCalendarStyle.plannerDayColumnColor(
        scheme,
        isToday: isToday,
      );
    canvas.drawRect(Offset.zero & size, columnPaint);

    const snap = ScheduleConstants.snapMinutes;
    final slotsPerHour = 60 ~/ snap;
    final hourCount = PlannerSlotGeometry.slotCount ~/ slotsPerHour;

    for (var hour = 0; hour < hourCount; hour++) {
      final y = PlannerSlotGeometry.yForMinutes(hour * 60, heightPerMinute);
      final hourHeight = PlannerSlotGeometry.yForMinutes(
        (hour + 1) * 60,
        heightPerMinute,
      ) - y;
      final bandPaint = Paint()
        ..color = ScheduleCalendarStyle.plannerHourBandColor(
          scheme,
          hour,
          isToday: isToday,
        );
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, hourHeight), bandPaint);
    }

    final dividerPaint = Paint()
      ..color = ScheduleCalendarStyle.plannerDayColumnDividerColor(scheme)
      ..strokeWidth = 0.75;
    canvas.drawLine(
      Offset(size.width - 0.5, 0),
      Offset(size.width - 0.5, size.height),
      dividerPaint,
    );
  }

  @override
  bool shouldRepaint(PlannerDaySlotBackgroundPainter oldDelegate) =>
      oldDelegate.scheme != scheme ||
      oldDelegate.day != day ||
      oldDelegate.isToday != isToday ||
      oldDelegate.heightPerMinute != heightPerMinute;
}

/// Hour-band backgrounds for the time gutter.
class PlannerTimeGutterBackgroundPainter extends CustomPainter {
  const PlannerTimeGutterBackgroundPainter({
    required this.scheme,
    required this.heightPerMinute,
  });

  final ColorScheme scheme;
  final double heightPerMinute;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = scheme.surfaceContainerLow.withValues(alpha: 0.65),
    );

    const snap = ScheduleConstants.snapMinutes;
    final slotsPerHour = 60 ~/ snap;
    final hourCount = PlannerSlotGeometry.slotCount ~/ slotsPerHour;

    for (var hour = 0; hour < hourCount; hour++) {
      final y = PlannerSlotGeometry.yForMinutes(hour * 60, heightPerMinute);
      final hourHeight = PlannerSlotGeometry.yForMinutes(
        (hour + 1) * 60,
        heightPerMinute,
      ) - y;
      final bandPaint = Paint()
        ..color = ScheduleCalendarStyle.plannerHourBandColor(scheme, hour);
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, hourHeight), bandPaint);
    }

    final dividerPaint = Paint()
      ..color = ScheduleCalendarStyle.plannerDayColumnDividerColor(scheme)
      ..strokeWidth = 0.75;
    canvas.drawLine(
      Offset(size.width - 0.5, 0),
      Offset(size.width - 0.5, size.height),
      dividerPaint,
    );
  }

  @override
  bool shouldRepaint(PlannerTimeGutterBackgroundPainter oldDelegate) =>
      oldDelegate.scheme != scheme ||
      oldDelegate.heightPerMinute != heightPerMinute;
}

/// Horizontal grid lines every 15 minutes; stronger lines on the hour.
class PlannerSlotGridPainter extends CustomPainter {
  const PlannerSlotGridPainter({
    required this.scheme,
    required this.heightPerMinute,
  });

  final ColorScheme scheme;
  final double heightPerMinute;

  @override
  void paint(Canvas canvas, Size size) {
    const snap = ScheduleConstants.snapMinutes;
    for (var slot = 0; slot <= PlannerSlotGeometry.slotCount; slot++) {
      final minutes = slot * snap;
      final y = PlannerSlotGeometry.yForMinutes(minutes, heightPerMinute);
      final isHour = minutes % 60 == 0;
      final isHalfHour = minutes % 60 == 30;
      final paint = Paint()
        ..color = isHour
            ? ScheduleCalendarStyle.plannerHourGridLineColor(scheme)
            : isHalfHour
                ? ScheduleCalendarStyle.plannerHalfHourGridLineColor(scheme)
                : ScheduleCalendarStyle.plannerQuarterHourGridLineColor(scheme)
        ..strokeWidth = isHour ? 1 : isHalfHour ? 0.6 : 0.35;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(PlannerSlotGridPainter oldDelegate) =>
      oldDelegate.scheme != scheme ||
      oldDelegate.heightPerMinute != heightPerMinute;
}

/// Time gutter: hour bands, grid lines, and hour labels aligned to the grid.
class PlannerTimeGutterPainter extends CustomPainter {
  const PlannerTimeGutterPainter({
    required this.scheme,
    required this.heightPerMinute,
  });

  final ColorScheme scheme;
  final double heightPerMinute;

  @override
  void paint(Canvas canvas, Size size) {
    PlannerTimeGutterBackgroundPainter(
      scheme: scheme,
      heightPerMinute: heightPerMinute,
    ).paint(canvas, size);

    PlannerSlotGridPainter(
      scheme: scheme,
      heightPerMinute: heightPerMinute,
    ).paint(canvas, size);

    final labelColor = ScheduleCalendarStyle.plannerHourLabelColor(scheme);
    const snap = ScheduleConstants.snapMinutes;

    for (var slot = 0; slot < PlannerSlotGeometry.slotCount; slot += 60 ~/ snap) {
      final hour = slot * snap ~/ 60;
      final y = PlannerSlotGeometry.yForSlot(slot, heightPerMinute);
      final time = TimeOfDay(hour: hour, minute: 0);
      final textPainter = TextPainter(
        text: TextSpan(
          text: DateTimeUtils.formatTimeOfDay(time),
          style: TextStyle(
            color: labelColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
      )..layout(maxWidth: size.width);

      textPainter.paint(
        canvas,
        Offset(size.width - textPainter.width, y + 2),
      );
    }

    final endY = PlannerSlotGeometry.yForMinutes(
      ScheduleConstants.minutesPerDay,
      heightPerMinute,
    );
    final midnightPainter = TextPainter(
      text: TextSpan(
        text: '24:00',
        style: TextStyle(
          color: labelColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    )..layout(maxWidth: size.width);
    midnightPainter.paint(
      canvas,
      Offset(size.width - midnightPainter.width, endY + 2),
    );
  }

  @override
  bool shouldRepaint(PlannerTimeGutterPainter oldDelegate) =>
      oldDelegate.scheme != scheme ||
      oldDelegate.heightPerMinute != heightPerMinute;
}
