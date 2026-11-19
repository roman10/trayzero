import 'package:flutter/material.dart';

/// An icon and label that can wrap within a card's available width.
class ItemMetadataLabel extends StatelessWidget {
  const ItemMetadataLabel({
    required this.text,
    required this.style,
    this.icon,
    this.iconSize = 12,
    this.maxLines,
    super.key,
  });

  final String text;
  final TextStyle style;
  final IconData? icon;
  final double iconSize;
  final int? maxLines;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (icon != null) ...[
        // Align the icon with the first text line as text scales.
        Padding(
          padding: EdgeInsets.only(
            top:
                (MediaQuery.textScalerOf(context).scale(style.fontSize ?? 12) *
                            (style.height ?? 1.2) -
                        iconSize)
                    .clamp(0, double.infinity) /
                2,
          ),
          child: Icon(icon, size: iconSize, color: style.color),
        ),
        const SizedBox(width: 4),
      ],
      Flexible(
        child: Text(
          text,
          style: style,
          maxLines: maxLines,
          overflow: maxLines == null
              ? TextOverflow.clip
              : TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
