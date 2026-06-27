import 'package:family_care_scheduler/core/theme/app_motion.dart';
import 'package:flutter/material.dart';

/// Rounded surface card with optional tap feedback — uses theme [CardTheme].
class AppCard extends StatefulWidget {
  const AppCard({
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: AppMotion.fast,
    );
    _scale = Tween<double>(begin: 1, end: AppMotion.pressScale).animate(
      CurvedAnimation(parent: _pressController, curve: AppMotion.emphasized),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = Card(
      margin: widget.margin ?? EdgeInsets.zero,
      color: widget.color,
      clipBehavior: Clip.antiAlias,
      child: widget.padding != null
          ? Padding(padding: widget.padding!, child: widget.child)
          : widget.child,
    );

    if (widget.onTap == null) return card;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) {
          _pressController.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () => _pressController.reverse(),
        child: card,
      ),
    );
  }
}
