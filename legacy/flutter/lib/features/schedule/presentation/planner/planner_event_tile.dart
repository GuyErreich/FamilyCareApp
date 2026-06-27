import 'package:flutter/material.dart';

/// Event block on the day/week planner.
class PlannerEventTile extends StatelessWidget {
  const PlannerEventTile({
    required this.title,
    required this.description,
    required this.color,
    required this.textColor,
    required this.height,
    this.isUnavailability = false,
    this.onTap,
    super.key,
  });

  final String title;
  final String description;
  final Color color;
  final Color textColor;
  final double height;
  final bool isUnavailability;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final showDescription = height >= 48;
    final fillAlpha = isUnavailability ? 0.12 : 0.2;

    return Material(
      color: color.withValues(alpha: fillAlpha),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isUnavailability
              ? color.withValues(alpha: 0.55)
              : scheme.outlineVariant.withValues(alpha: 0.35),
          width: isUnavailability ? 1 : 0.75,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              color: color,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: height < 44 ? 11 : 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (showDescription)
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
