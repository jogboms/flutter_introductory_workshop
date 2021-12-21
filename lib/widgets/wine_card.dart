import 'package:flutter/material.dart';
import 'package:flutter_introductory_workshop/domain.dart';

import 'star_rating.dart';
import 'wine_image.dart';

class WineCard extends StatelessWidget {
  const WineCard({Key? key, required this.wine, required this.onPressed}) : super(key: key);

  final Wine wine;
  final ValueChanged<Wine> onPressed;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onPressed(wine),
            child: Ink(color: Colors.white, child: _WineCardInfo(wine: wine)),
          ),
        ),
      );
}

class _WineCardInfo extends StatelessWidget {
  const _WineCardInfo({Key? key, required this.wine}) : super(key: key);

  final Wine wine;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: <Widget>[
                Positioned.fill(child: WineImage(path: wine.imagePath)),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).colorScheme.onPrimary.withOpacity(.75),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          wine.year.toString(),
                          style: Theme.of(context).textTheme.caption?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  wine.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: StarRating(rating: wine.rating),
          ),
          const SizedBox(height: 10),
        ],
      );
}
