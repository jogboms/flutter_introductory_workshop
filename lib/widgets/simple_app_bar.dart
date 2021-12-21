import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show AppBar;

class SimpleAppBar extends AppBar {
  SimpleAppBar({Key? key, String? title, List<Widget>? actions})
      : super(
          key: key,
          title: title != null ? Text(title) : null,
          centerTitle: true,
          elevation: 0,
          foregroundColor: CupertinoColors.black,
          backgroundColor: CupertinoColors.white,
          actions: actions,
        );
}
