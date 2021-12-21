import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show IconButton;

class StarRating extends StatelessWidget {
  const StarRating({Key? key, required this.rating, this.onPressed}) : super(key: key);

  final int rating;
  final ValueChanged<int>? onPressed;

  @override
  Widget build(BuildContext context) => Row(
        children: List<Widget>.generate(
          5,
          (int index) {
            final bool isSolid = index + 1 <= rating;
            return IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tight(Size.square(onPressed != null ? 32 : 24)),
              onPressed: onPressed != null ? () => onPressed?.call(index + 1) : null,
              icon: Icon(
                isSolid ? CupertinoIcons.star_fill : CupertinoIcons.star,
                color: isSolid ? CupertinoColors.activeOrange : CupertinoColors.lightBackgroundGray,
              ),
            );
          },
        ),
      );
}
