import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_introductory_workshop/store.dart';

class AddRandomWineButton extends StatelessWidget {
  const AddRandomWineButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: () => context.store.add().then((String? id) => id == null
            ? Null
            : context.store.update(
                id,
                name: id.substring(0, 10),
                rating: Random().nextInt(5),
                year: 1000 + Random().nextInt(1000),
                imagePath: '',
              )),
        icon: const Icon(Icons.rotate_90_degrees_ccw_rounded),
      );
}
