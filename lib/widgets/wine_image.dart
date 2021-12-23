import 'dart:io';

import 'package:flutter/material.dart';

class WineImage extends StatelessWidget {
  const WineImage({Key? key, required this.path, this.onPressed}) : super(key: key);

  final String path;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Material(
        child: InkWell(
          onTap: onPressed,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.file(File(path), errorBuilder: (_, __, ___) => const Material(color: Colors.grey)),
              if (onPressed != null)
                Center(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(32)),
                    padding: const EdgeInsets.all(16),
                    child: const Icon(Icons.add_a_photo, size: 32, color: Colors.grey),
                  ),
                )
            ],
          ),
        ),
      );
}
