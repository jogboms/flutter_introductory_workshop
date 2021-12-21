import 'package:flutter/material.dart';
import 'package:flutter_introductory_workshop/widgets.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({Key? key}) : super(key: key);

  static Future<String?> go(BuildContext context) =>
      Navigator.of(context).push<String>(MaterialPageRoute<String>(builder: (_) => const CameraPage()));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: MaterialButton(
            onPressed: Navigator.of(context).maybePop,
            shape: const CircleBorder(),
            color: Colors.black38,
            textColor: Colors.white,
            child: const Icon(Icons.close),
          ),
        ),
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: CameraView(onComplete: Navigator.of(context).pop),
      );
}
