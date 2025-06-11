import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ThemedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? margin;
  final double? size;
  final double borderRadius;

  const ThemedIconButton({
    super.key,
    this.icon = FontAwesomeIcons.arrowLeft,
    this.onPressed,
    this.margin = const EdgeInsets.only(left: 16, top: 8, bottom: 8),
    this.size = 18,
    this.borderRadius = 12,
  });

  const ThemedIconButton.back({
    super.key,
    this.margin = const EdgeInsets.only(left: 16, top: 8, bottom: 8),
    this.size = 18,
    this.borderRadius = 12,
  })  : icon = FontAwesomeIcons.arrowLeftLong,
        onPressed = null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: colorScheme.onSurface,
          size: size,
        ),
        onPressed: onPressed ?? () => Navigator.pop(context),
      ),
    );
  }
}
