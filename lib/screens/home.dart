import 'package:flutter/cupertino.dart' show CupertinoColors;
import 'package:flutter/material.dart';
import 'package:flutter_introductory_workshop/domain.dart';
import 'package:flutter_introductory_workshop/store.dart';
import 'package:flutter_introductory_workshop/widgets.dart';

import 'details.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Store store = context.store;

  late final ValueNotifier<String> filterValue = ValueNotifier<String>('');
  late final ValueNotifier<SortType> sortTypeValue = ValueNotifier<SortType>(SortType.none);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: CupertinoColors.systemGrey6,
        appBar: SimpleAppBar(
          title: widget.title,
          actions: const <Widget>[AddRandomWineButton()],
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverPersistentHeader(
              pinned: true,
              delegate: SearchBarSliverPersistentHeaderDelegate(
                (_) => ValueListenableBuilder<SortType>(
                  valueListenable: sortTypeValue,
                  builder: (_, SortType value, __) => TopBar(onSort: onSort, onSearch: onSearch, sortType: value),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 4)),
            SliverPadding(
              padding: const EdgeInsets.all(8),
              sliver: AnimatedBuilder(
                animation: Listenable.merge(<Listenable>[store, filterValue, sortTypeValue]),
                child: const SliverFillRemaining(child: Center(child: Text('No data available'))),
                builder: (BuildContext context, Widget? child) {
                  final List<Wine> items =
                      sortAndFilter(store.items, filterBy: filterValue.value, sortBy: sortTypeValue.value);
                  if (items.isEmpty) {
                    return child!;
                  }

                  return SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1 / 1.35,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) => WineCard(
                        wine: items[index],
                        onPressed: (Wine wine) => DetailsPage.go(context, id: wine.id),
                      ),
                      childCount: items.length,
                    ),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => DetailsPage.go(context),
          child: const Icon(Icons.add),
        ),
      );

  void onSort(SortType type) => sortTypeValue.value = type;

  void onSearch(String input) => filterValue.value = input;

  List<Wine> sortAndFilter(List<Wine> items, {String filterBy = '', SortType? sortBy}) => items
      .where((Wine element) => filterBy.isEmpty || element.name.toLowerCase().contains(filterValue.value.toLowerCase()))
      .toList(growable: false)
    ..sort((Wine a, Wine b) {
      switch (sortTypeValue.value) {
        case SortType.year:
          return a.year.compareTo(b.year);
        case SortType.rating:
          return b.rating.compareTo(a.rating);
        case SortType.name:
          return a.name.compareTo(b.name);
        case SortType.createdAt:
        case SortType.none:
        default:
          return a.createdAt.compareTo(b.createdAt);
      }
    });
}

class SearchBarSliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  SearchBarSliverPersistentHeaderDelegate(this.builder);

  Widget Function(BuildContext) builder;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      SizedBox(height: maxExtent, child: builder(context));

  @override
  double get maxExtent => minExtent;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SearchBarSliverPersistentHeaderDelegate oldDelegate) => false;
}
