---
sidebar_position: 3
---

# Data Layer

We are getting into the thick of it now. 

From the last chapter, our entire business logic was just a collection aka `List` within our `HomePage`. 
You can take a look at our last results in this [DartPad](https://dartpad.dev/?id=27b53f2f87ae56cf10037f6e49ad925a).

We need an encapsulation for the improved business logic. We shall call this contraption `Store`.
And for now it will have just an `items` getter for all the `Wine` items and an initializer to populate these items in its constructor.

You can paste this snippet anywhere of your choosing with the *Pad*.

```dart
class Store {
  Store([List<Wine> items = const <Wine>[]])
      : _items = items.fold<Map<String, Wine>>(
            <String, Wine>{}, (Map<String, Wine> map, Wine wine) => map..putIfAbsent(wine.id, () => wine));

  List<Wine> get items => _items.values.toList(growable: false);
  final Map<String, Wine> _items;
}
```

Remember the dummy data you added to the `HomePage` from [Getting Started](./getting-started.md), 
you are going to replace it with an instance of the newly-created `Store`.

You can create an instance of the `Store` with the dummy data. You should preferably place this snippet closer to the top of the *Pad*. 
Somewhere above the `main` entry function.

```dart
final Store store = Store(List<Wine>.generate(10, (int index) {
  return Wine(
    id: shortHash(index * 1000),
    imageId: 1 + Random().nextInt(35),
    name: 'Wine $index',
    rating: Random().nextInt(6),
    year: 1200 + index,
  );
}));
```

With this in place, we replace the use of `wines` in the `GridView` with `store.items` instead.

## Feature set

We have a couple of capabilities we would like our application to have.
- **Add**. We need to be able to remove items from the store.
- **Update**. We need to be able to update items present in the store.
- **Remove**. We need to be able to remove items from the store.

### Wine removal

First feature we would like to implement is the `remove` feature. For this, we would first modify the `SharedAppBar` to take an extra optional `trailing` parameter.
This would be of type `Widget` because we want to be able to add a remove button on the top of the `DetailsPage`.

```dart
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
```

With this, we can add a *"delete"* [IconButton](https://api.flutter.dev/flutter/material/IconButton-class.html) as the `trailing` parameter on the `DetailsPage`'s `SharedAppBar` using the said `trailing` property.

```dart
SharedAppBar(
  trailing: IconButton(
    onPressed: () {},
    icon: const Icon(Icons.delete),
  ),
)
```

For now, it does nothing and this leads on to the next step which is implementing the actual `remove` ability in our `Store`.

```dart
void remove(String id) {
  _items.removeWhere((String wineId, _) => wineId == id);
}
```

And then call the said `remove` method on the `onPressed` callback of the *"delete"* `IconButton`.
After removing, we also want to go back to the `HomePage` hence the `Navigator.pop(context)` as the opposing API to `Navigator.push` used to get there in the first place.

```dart
store.remove(widget.wine.id);
Navigator.pop(context);
```

Oh! wait, nothing actually happened.

At least nothing happened on the display, the removed item is still clearly visible in the Grid.
That's because the `Store` itself is not reactive to changes within the `items` property so even though the item is indeed removed, the interface cannot tell when this happens.
With that comes the [ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html).
This allows the `Store` to be able to publish when changes have occurred, and it also exposes an interface for the interface to subscribe to these changes.

To implement this, we do two (2) things.
- We `mixin` the `ChangeNotifier` with our `Store` class definition
- On every change we need the interface to react to, we call [`notifyListeners()`](https://api.flutter.dev/flutter/foundation/ChangeNotifier/notifyListeners.html)

```dart
class Store with ChangeNotifier {
  Store([List<Wine> items = const <Wine>[]])
      : _items = items.fold<Map<String, Wine>>(
            <String, Wine>{}, (Map<String, Wine> map, Wine wine) => map..putIfAbsent(wine.id, () => wine));

  List<Wine> get items => _items.values.toList(growable: false);
  final Map<String, Wine> _items;

  void remove(String id) {
    _items.removeWhere((String wineId, _) => wineId == id);
    notifyListeners(); // This is how we publish that a change has occurred
  }
}
```

And then, to automatically subscribe to the changes within the `Store`, we wrap our `GridView` with the [AnimatedBuilder](https://api.flutter.dev/flutter/widgets/AnimatedBuilder-class.html).
I know right, it is not exactly an animation, but it is hard to judge when you get it for free.
This would rebuild the contents in the `builder` whenever the `Store` sends a notification.

```dart
AnimatedBuilder(
  animation: store,
  builder: (BuildContext context, Widget? child) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1 / 1.25,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: store.items.length,
      itemBuilder: (BuildContext context, int index) {
        final Wine wine = store.items[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(builder: (_) => DetailsPage(wine: wine)),
            );
          },
          child: WineCard(key: Key(wine.id), wine: wine),
        );
      },
    );
  },
)
```

### Wine modification

Up next is the implementation detail of the `update` feature. You can update the `Store` with the snippet below.

```dart
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
```

Then we would next input fields in place of the static `Text` widgets in the `DetailsPage`. As usual, a tidy widget exists for this.
We would replace the `Text` widgets with `TextFormField` widgets and whenever there is a change in the field, the `onChange` callback is called.
At this point, we would call the `update` method of the `Store` with the field's current value.

```dart
// Name field
TextFormField(
  initialValue: widget.wine.name,
  onChanged: (String value) => store.update(widget.wine.id, name: value),
  decoration: const InputDecoration(border: OutlineInputBorder()),
)
```
```dart
// Year field
TextFormField(
  initialValue: '${widget.wine.year}',
  onChanged: (String value) => store.update(widget.wine.id, year: int.parse(value)),
  decoration: const InputDecoration(border: OutlineInputBorder()),
)
```

We would need a similar procedure for the star rating. We start by adding a optional `onChanged` callback property for when any of the stars are clicked.

```dart
class StarRating extends StatelessWidget {
  const StarRating({Key? key, required this.rating, this.onChanged}) : super(key: key);

  final int rating;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(
        5,
        (int index) {
          final bool isSolid = index + 1 <= rating;
          return IconButton(
            key: ValueKey<int>(index),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tight(const Size.square(24)),
            onPressed: onChanged != null ? () => onChanged?.call(index + 1) : null, // This is where we trigger the callback
            icon: Icon(
              isSolid ? Icons.star : Icons.star_border,
              color: isSolid ? Colors.orangeAccent : Colors.grey,
            ),
          );
        },
      ),
    );
  }
}
```

And with that done, we can replicate calling the `update` method whenever the rating value changes.

```dart
StarRating(
  rating: widget.wine.rating,
  onChanged: (int value) => store.update(widget.wine.id, rating: value),
)
```

Oh! wait, nothing actually happened.

Something strange again, the interface is not updating. That is because we built no visual feedback to update the `StarRating` widget whenever a star is clicked.
For this, we would reuse the [FormField](https://api.flutter.dev/flutter/widgets/FormField-class.html) widget from the framework.
And to make sure we stay truly up-to-date, we would override the [`didUpdateWidget`](https://api.flutter.dev/flutter/widgets/State/didUpdateWidget.html)
lifecycle hook so that if the field value is somehow changed from the outside, this widget would also update itself.

```dart
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
                          field.didChange(value); // This is where we update the state of the field
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
```

### Wine creation

To finish up the feature set, we implement the `add` feature. You can update the `Store` with the snippet below.

```dart
Wine add() {
  final String id = shortHash(1000 + Random().nextInt(1000));
  final Wine wine = Wine(id: id, imageId: 1 + Random().nextInt(35), name: '', rating: 0, year: 0);
  _items.putIfAbsent(id, () => wine);
  notifyListeners();
  return wine;
}
```

And to trigger the `add` action, we would introduce a [FloatingActionButton](https://api.flutter.dev/flutter/material/FloatingActionButton-class.html) to the `HomePage`'s interface.
It is basically a button that floats. In the `HomePage`'s `Scaffold`, it exposes a property called `floatingActionButton`. We set the value to the snippet below.

```dart
FloatingActionButton(
  onPressed: () {
    final Wine wine = store.add();
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => DetailsPage(wine: wine)),
    );
  },
  child: const Icon(Icons.add),
)
```

## Round up

With the feature set complete, you can choose to remove the dummy data initializer or not.

All things being equal, you should still have a functioning `Flutter` app.
You can compare and even see this in action via this [DartPad](https://dartpad.dev/?id=461e03f8ac09cb05f195e3ea6aff25a6)
