import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_introductory_workshop/domain.dart';

class TopBar extends StatelessWidget {
  const TopBar({Key? key, required this.onSearch, required this.onSort, required this.sortType}) : super(key: key);

  final ValueChanged<String> onSearch;
  final ValueChanged<SortType> onSort;
  final SortType sortType;

  @override
  Widget build(BuildContext context) => Material(
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 4),
          child: Row(
            children: <Widget>[
              Expanded(
                child: CupertinoTextField(
                  onChanged: onSearch,
                  clearButtonMode: OverlayVisibilityMode.editing,
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<SortType>(
                icon: Icon(
                  Icons.sort,
                  color: sortType != SortType.none ? Theme.of(context).colorScheme.primary : Colors.grey,
                ),
                onSelected: onSort,
                initialValue: sortType,
                itemBuilder: (_) => <PopupMenuEntry<SortType>>[
                  for (final SortType item in SortType.values)
                    PopupMenuItem<SortType>(value: item, child: Text(item.displayName)),
                ],
              ),
            ],
          ),
        ),
      );
}
