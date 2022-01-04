import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const String imagesApi = 'https://flutter-introductory-workshop.vercel.app/api/images';
final Store store = Store();

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ValueNotifier<String> searchValue = ValueNotifier<String>('');
  late final ValueNotifier<SortType> sortTypeValue = ValueNotifier<SortType>(SortType.none);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPersistentHeader(
            pinned: true,
            delegate: ToolBarSliverPersistentHeaderDelegate(
              (_) => ValueListenableBuilder<SortType>(
                valueListenable: sortTypeValue,
                builder: (BuildContext context, SortType value, Widget? child) {
                  return ToolBar(
                    onSearch: (String value) => searchValue.value = value,
                    onSort: (SortType value) => sortTypeValue.value = value,
                    sortType: sortTypeValue.value,
                  );
                },
              ),
            ),
          ),
          AnimatedBuilder(
            animation: Listenable.merge(<Listenable>[store, searchValue, sortTypeValue]),
            builder: (BuildContext context, Widget? child) {
              final List<Wine> wines = store.items
                  .where((Wine element) =>
                      searchValue.value.isEmpty || element.name.toLowerCase().contains(searchValue.value.toLowerCase()))
                  .toList(growable: false)
                ..sort((Wine a, Wine b) {
                  switch (sortTypeValue.value) {
                    case SortType.year:
                      return a.year.compareTo(b.year);
                    case SortType.rating:
                      return b.rating.compareTo(a.rating);
                    case SortType.name:
                      return a.name.compareTo(b.name);
                    case SortType.none:
                      return a.id.compareTo(b.id);
                  }
                });
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1 / 1.25,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final Wine wine = wines[index];
                      return GestureDetector(
                        key: Key(wine.id),
                        onTap: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(builder: (_) => DetailsPage(wine: wine)),
                          );
                        },
                        child: WineCard(wine: wine),
                      );
                    },
                    childCount: wines.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final Wine wine = store.add();
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(builder: (_) => DetailsPage(wine: wine)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DetailsPage extends StatefulWidget {
  const DetailsPage({Key? key, required this.wine}) : super(key: key);

  final Wine wine;

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(
        trailing: IconButton(
          onPressed: () {
            store.remove(widget.wine.id);
            Navigator.pop(context);
          },
          icon: const Icon(Icons.delete),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AspectRatio(aspectRatio: 1.5, child: Image.network('$imagesApi/${widget.wine.imageId}')),
            const SizedBox(height: 24),
            TextFormField(
              initialValue: widget.wine.name,
              onChanged: (String value) => store.update(widget.wine.id, name: value),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: '${widget.wine.year}',
              onChanged: (String value) => store.update(widget.wine.id, year: int.parse(value)),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            StarRating(
              rating: widget.wine.rating,
              onChanged: (int value) => store.update(widget.wine.id, rating: value),
            ),
          ],
        ),
      ),
    );
  }
}

class ToolBar extends StatelessWidget {
  const ToolBar({Key? key, required this.onSearch, required this.onSort, required this.sortType}) : super(key: key);

  final ValueChanged<String> onSearch;
  final ValueChanged<SortType> onSort;
  final SortType sortType;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                onChanged: onSearch,
                decoration: const InputDecoration(hintText: 'Search...', border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<SortType>(
              icon: const Icon(Icons.sort, color: Colors.grey),
              onSelected: onSort,
              initialValue: sortType,
              itemBuilder: (_) => SortType.values
                  .map((SortType item) => PopupMenuItem<SortType>(value: item, child: Text(item.displayName)))
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}

class SharedAppBar extends AppBar {
  SharedAppBar({Key? key, Widget? trailing})
      : super(
          key: key,
          title: const Text('Winery'),
          centerTitle: true,
          elevation: 0,
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          actions: <Widget>[if (trailing != null) trailing],
        );
}

class WineCard extends StatelessWidget {
  const WineCard({Key? key, required this.wine}) : super(key: key);

  final Wine wine;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      borderRadius: const BorderRadius.all(Radius.circular(6)),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: <Widget>[
                Positioned.fill(child: Image.network('$imagesApi/${wine.imageId}')),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
          const SizedBox(height: 6),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(wine.name, style: Theme.of(context).textTheme.subtitle1),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: StarRating(rating: wine.rating),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class StarRating extends FormField<int> {
  StarRating({Key? key, required int rating, ValueChanged<int>? onChanged})
      : super(
          key: key,
          initialValue: rating,
          builder: (FormFieldState<int> field) {
            final int rating = field.value ?? 0;
            return Row(
              children: List<Widget>.generate(5, (int index) {
                final int value = index + 1;
                final bool isSolid = value <= rating;
                return IconButton(
                  key: ValueKey<int>(index),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(const Size.square(24)),
                  onPressed: onChanged == null
                      ? null
                      : () {
                          field.didChange(value);
                          onChanged.call(value);
                        },
                  icon: Icon(
                    isSolid ? Icons.star : Icons.star_border,
                    color: isSolid ? Colors.orangeAccent : Colors.grey,
                  ),
                );
              }),
            );
          },
        );

  @override
  _StarRatingState createState() => _StarRatingState();
}

class _StarRatingState extends FormFieldState<int> {
  @override
  void didUpdateWidget(StarRating oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setValue(widget.initialValue);
    }
  }
}

class ToolBarSliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  ToolBarSliverPersistentHeaderDelegate(this.builder);

  Widget Function(BuildContext) builder;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      SizedBox.expand(child: builder(context));

  @override
  double get maxExtent => minExtent;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(ToolBarSliverPersistentHeaderDelegate oldDelegate) => false;
}

class Store with ChangeNotifier {
  Store([List<Wine> items = const <Wine>[]])
      : _items = items.fold<Map<String, Wine>>(
            <String, Wine>{}, (Map<String, Wine> map, Wine wine) => map..putIfAbsent(wine.id, () => wine));

  List<Wine> get items => _items.values.toList(growable: false);
  final Map<String, Wine> _items;

  Wine add() {
    final String id = shortHash(1000 + Random().nextInt(1000));
    final Wine wine = Wine(id: id, imageId: 1 + Random().nextInt(35), name: '', rating: 0, year: 0);
    _items.putIfAbsent(id, () => wine);
    notifyListeners();
    return wine;
  }

  void remove(String id) {
    _items.removeWhere((String wineId, _) => wineId == id);
    notifyListeners();
  }

  void update(String id, {String? name, int? year, int? rating}) {
    _items.update(
      id,
      (Wine prev) => Wine(
        id: prev.id,
        imageId: prev.imageId,
        name: name ?? prev.name,
        rating: rating ?? prev.rating,
        year: year ?? prev.year,
      ),
    );
    notifyListeners();
  }
}

class Wine {
  const Wine({required this.id, required this.imageId, required this.name, required this.rating, required this.year});

  final String id;
  final int imageId;
  final String name;
  final int rating;
  final int year;

  @override
  bool operator ==(covariant Wine other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          id == other.id &&
          imageId == other.imageId &&
          name == other.name &&
          rating == other.rating &&
          year == other.year;

  @override
  int get hashCode => id.hashCode ^ imageId.hashCode ^ name.hashCode ^ rating.hashCode ^ year.hashCode;

  @override
  String toString() => 'Wine{id: $id, imageId:$imageId, name: $name, rating: $rating, year: $year}';
}

enum SortType { none, name, rating, year }

extension SortTypeExtension on SortType {
  String get displayName => <SortType, String>{
        SortType.none: 'None',
        SortType.name: 'Name',
        SortType.rating: 'Rating',
        SortType.year: 'Year',
      }[this]!;
}
