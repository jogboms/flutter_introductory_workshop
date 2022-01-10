---
sidebar_position: 4
---

# Filter and Sort

### You made it! 👌🏿

You made it to the final phase of this journey. To recap, you can take a look at our last results in this [DartPad](https://dartpad.dev/?id=461e03f8ac09cb05f195e3ea6aff25a6).

Now we transition into the murky waters of [Slivers](https://medium.com/flutter/slivers-demystified-6ff68ab0296f).
Fortunately, we do not have to do a deep dive or spend too much time within the mist.
We basically want just want to implement one tiny feature; To include a fixed header beneath the `SharedAppBar`.
Sounds trivial, yeah?, so we begin.

First, we wrap the contents of the `body` property of the `HomePage`'s `Scaffold` with a [CustomScrollView](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html).

Then we would replace the `GridView` with a [SliverGrid](https://api.flutter.dev/flutter/widgets/SliverGrid-class.html) and this would come with some changes.

At the end, it should look somewhat similar to (if not exactly as) the snippet below.

```dart
CustomScrollView(
  slivers: <Widget>[
    AnimatedBuilder(
      animation: store,
      builder: (BuildContext context, Widget? child) {
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
                final Wine wine = store.items[index];
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
              childCount: store.items.length,
            ),
          ),
        );
      },
    ),
  ],
)
```

## Toolbar

Let us introduce a new `StatelessWidget` called `ToolBar` to house the search and sort feature.
For now it does nothing with an empty [Material](https://api.flutter.dev/flutter/material/Material-class.html) widget just to keep it simple.

```dart
class ToolBar extends StatelessWidget {
  const ToolBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Material();
  }
}
```

Then, in order to have this pinned at the top beneath the `SharedAppBar` we need to implement a certain [SliverPersistentHeaderDelegate](https://api.flutter.dev/flutter/widgets/SliverPersistentHeaderDelegate-class.html) with the preferred height ([kToolbarHeight](https://api.flutter.dev/flutter/material/kToolbarHeight-constant.html)) of the `ToolBar`.

```dart
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
```

And finally putting both together, we place this `ToolBar` widget above the `AnimatedBuilder` as the first item of the `CustomScrollerView`'s `slivers` list.

```dart
SliverPersistentHeader(
  pinned: true,
  delegate: ToolBarSliverPersistentHeaderDelegate(
        (_) => const ToolBar(),
  ),
)
```

## Feature set

We only have two (2) capabilities we would like to implement here.
- **Filter**. We need to be able to filter the wine items in grid by a *"search"* value.
- **Sort**. We need to be able to re-arrange the wine items by certain criteria.

### Wine name filter

First, we introduce the filter search field and by convention include a `onSearch` callback for whenever the value changes.
Your `ToolBar` should look like the snippet below.

```dart
class ToolBar extends StatelessWidget {
  const ToolBar({Key? key, required this.onSearch}) : super(key: key);

  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TextField(
          onChanged: onSearch,
          decoration: const InputDecoration(hintText: 'Search...', border: OutlineInputBorder()),
        ),
      ),
    );
  }
}
```

Then make the required changes.

```dart
ToolBar(onSearch: (String value) {})
```

Because the interface has to be completely reactive, It would be clever to persist the value of the search field in a *"reactive"* wrapper of some sort.
Much like how the `Store` uses the `ChangeNotifier` the [ValueNotifier](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html) is an easy-to-use abstraction on top of the `ChangeNotifier` for single value types.

We create this as a variable in the `_HomePageState` and initialize it to an empty string.

```dart
late final ValueNotifier<String> searchValue = ValueNotifier<String>('');
```

Next, we redirect the changes from the search field through the `ValueNotifier` by just changing its value.

```dart
ToolBar(onSearch: (String value) => searchValue.value = value)
```

Then, in order for the `AnimatedBuilder` to rebuild on changes from both the `Store` and the search field's `ValueNotifier`,
we incorporate the tidy [Listenable.merge](https://api.flutter.dev/flutter/foundation/Listenable/Listenable.merge.html) utility to combine both `ChangeNotifier`s into one.

```dart
animation: Listenable.merge(<Listenable>[store, searchValue]),
```

And finally, within the `builder` of the `AnimatedBuilder`, we implement the *"search"* logic.
Instead of using `store.items` directly we now use `wines` to build the grid.

```dart
final List<Wine> wines = store.items
    .where((Wine element) =>
        searchValue.value.isEmpty || element.name.toLowerCase().contains(searchValue.value.toLowerCase()))
    .toList(growable: false);
```

### Wine sorting

Sorting is the final piece of this task, and we are going to sort our wine items on the following parameters.
- The name of the wine
- The star rating given to the wine
- The year the wine was released

First an enumerator to describe the different choices for sorting.

```dart
enum SortType { none, name, rating, year }

extension SortTypeExtension on SortType {
  String get displayName => <SortType, String>{
        SortType.none: 'None',
        SortType.name: 'Name',
        SortType.rating: 'Rating',
        SortType.year: 'Year',
      }[this]!;
}
```

We improve the `ToolBar` with an `onSort` callback for when the user makes a choice and a [PopupMenuButton](https://api.flutter.dev/flutter/material/PopupMenuButton-class.html) to present the choices of the property to sort by.

```dart
class ToolBar extends StatelessWidget {
  const ToolBar({Key? key, required this.onSearch, required this.onSort}) : super(key: key);

  final ValueChanged<String> onSearch;
  final ValueChanged<SortType> onSort;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row( // Needed to add a Row to fit in the widgets
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
              initialValue: SortType.none,
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
```

Then, make the required changes.

```dart
ToolBar(
  onSearch: (String value) => searchValue.value = value,
  onSort: (SortType value) {},
)
```

Much like the search field's `ValueNotifier`, We would replicate the exact same behaviour for sorting.

```dart
late final ValueNotifier<SortType> sortTypeValue = ValueNotifier<SortType>(SortType.none);
```
```dart
ToolBar(
  onSearch: (String value) => searchValue.value = value,
  onSort: (SortType value) => sortTypeValue.value = value,
)
```
```dart
animation: Listenable.merge(<Listenable>[store, searchValue, sortTypeValue]),
```

With all that done, we implement the actual sorting function. Do append this logic (using the [Cascade notation](https://dart.dev/guides/language/language-tour#cascade-notation)) to the previous search logic (Add it after the `.toList(growable: false)`).

```dart
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
})
```

As a bonus point, we would like the `PopupMenuButton` to show the current state of the sorting at all times.

Much like the `AnimatedBuilder`, the [ValueListenableBuilder](https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html) is a handy utility for automatically subscribing to a `ValueNotifier`'s changes.

With this knowledge, we would wrap the `ToolBar` with the `ValueListenableBuilder` and subscribe only to the sort type's `ValueNotifier` so we can know it's state at all times.

```dart
ValueListenableBuilder<SortType>(
  valueListenable: sortTypeValue,
  builder: (BuildContext context, SortType value, Widget? child) {
    return ToolBar(
      onSearch: (String value) => searchValue.value = value,
      onSort: (SortType value) => sortTypeValue.value = value,
      sortType: sortTypeValue.value,
    );
  },
)
```

Then modify the `ToolBar` to receive the previous `SortType` so we can pass that on to the `PopupMenuButton`

```dart
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
              initialValue: sortType, // Set the previous value here
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
```

## Round up

With that we come to the end of the practical session.

All things being equal, you should still have a functioning `Flutter` app.
You can compare and even see this in action via this [DartPad](https://dartpad.dev/?id=d74163b9742d9cbca4ef3405196bb6e1)
