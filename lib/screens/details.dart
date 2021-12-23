import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_introductory_workshop/domain.dart';
import 'package:flutter_introductory_workshop/store.dart';
import 'package:flutter_introductory_workshop/widgets.dart';

import 'camera.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({Key? key, this.id}) : super(key: key);

  final String? id;

  static void go(BuildContext context, {String? id}) =>
      Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (BuildContext context) => DetailsPage(id: id)));

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late final Store store = context.store;

  late final TextEditingController nameController = TextEditingController();
  late final TextEditingController yearController = TextEditingController();

  late String? id = widget.id;

  static const Widget loadingWidget = Center(child: CircularProgressIndicator());

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (widget.id == null) {
        store.add().then((String? value) {
          if (value != null) {
            setState(() => id = value);
          }
        });
      } else {
        final Wine wine = store.get(id!)!;
        nameController.text = wine.name;
        yearController.text = wine.year.toString();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    yearController.dispose();
    super.dispose();
  }

  Future<bool> checkIfCanClose() async {
    final Wine wine = store.get(id!)!;
    if (wine.isEmpty) {
      await store.remove(id!);
      return true;
    }
    if (wine.isNotComplete) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incomplete field(s)')));
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: checkIfCanClose,
        child: Scaffold(
          appBar: SimpleAppBar(
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  store.remove(id!);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.delete),
                color: CupertinoColors.destructiveRed,
              ),
            ],
          ),
          body: AnimatedBuilder(
            animation: store,
            builder: (BuildContext context, _) {
              if (id == null) {
                return loadingWidget;
              }

              late final Wine? wine = store.get(id!);
              if (wine == null) {
                return loadingWidget;
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 1,
                      child: WineImage(
                        path: wine.imagePath,
                        onPressed: () => CameraPage.go(context)
                            .then((String? path) => path == null ? Null : store.update(wine.id, imagePath: path)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const _FieldLabel('NAME'),
                          CupertinoTextField(
                            controller: nameController,
                            onChanged: (String value) => store.update(wine.id, name: value),
                          ),
                          const _FieldLabel('YEAR'),
                          CupertinoTextField(
                            controller: yearController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            onChanged: (String value) {
                              if (value.length == 4) {
                                store.update(wine.id, year: int.parse(value));
                              }
                            },
                          ),
                          const _FieldLabel('RATING'),
                          StarRating(
                            rating: wine.rating,
                            onPressed: (int rating) => store.update(wine.id, rating: rating),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label, {Key? key}) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 14),
        child: Text(label, style: Theme.of(context).textTheme.caption),
      );
}
