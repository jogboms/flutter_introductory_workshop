---
sidebar_position: 2
---

# Getting Started

## Hello world

As earlier stated, we would be making use a [hosted version](https://dartpad.dev) of the SDK. Visit the link to get familiar with its environment.
Its open-source and free but does not support code hosting which means what ever code you write in there would not be persisted.

For that we would use the [Github Gists](https://gist.github.com) service. It is easy to use if you already have a Github account and has nice integrations with *DartPad*.
Otherwise, you could also just copy-and-paste the code where ever you like as well.

With that out of the way, we begin by scaffolding the customary *"hello world"* application.

To do that, simply go to Dartpad and click on the **New Pad** menu option at the top. You should be presented with a dialog to create a new *Dart* or *Flutter* *pad*.
Choose the *Flutter* option and click on **Create**.

Then to run the application, simply click on the bright blue **Run** button. *Viola!* First challenge completed!

Let us try to dissect what exactly is going on here.

## Application identity

Let us make some modifications, Same *"hello world"* but just slightly tweaked towards our final goal. Replace the contents of the *pad* with the snippet below.

```dart
import 'package:flutter/material.dart';

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
      home: const Scaffold(
        body: Center(
          child: Text('Hello, World!'),
        ),
      ),
    );
  }
}
```

Next we want the world to know the name of our application. With this, we introduce a tidy widget called the [AppBar](https://api.flutter.dev/flutter/material/AppBar-class.html).
Then, knowing our `Scaffold` widget accepts a `appBar` property, we would add our `AppBar` there with a `title` of a [Text](https://api.flutter.dev/flutter/widgets/Text-class.html) widget with contents of our application name, *"Winery"*.

Copy the snippet below, you would paste it as the `appBar` property of the `Scaffold`.

```dart
AppBar(
  title: const Text('Winery'),
  centerTitle: true,
  elevation: 0,
  foregroundColor: Colors.black,
  backgroundColor: Colors.white,
)
```

The result should be like the snippet below.

```dart
class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: Scaffold( // <- We also had to remove the `const` that was here 
        // This is where it goes
        appBar: AppBar( 
          title: const Text('Winery'),
          centerTitle: true,
          elevation: 0,
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
        ),
        // ^ Ends in the line above
        body: Center(
          child: Text('Hello, World!'),
        ),
      ),
    );
  }
}
```

Next, looking at the screenshot below, we have to design the card-like interface for displaying the wine image.

<img src="/screenshots/05.png" width="300" />
<br/><br/>

I would ask that you place the snippet below as a replacement of the contents of `body` on the `Scaffold` widget.
It consists a simple [Container](https://api.flutter.dev/flutter/widgets/Container-class.html), a [Column](https://api.flutter.dev/flutter/widgets/Column-class.html),
a [ColoredBox](https://api.flutter.dev/flutter/widgets/ColoredBox-class.html) and a couple of other widgets.
We would make some further tweaks but we would keep it simple for now.

```dart
Container(
  width: 240,
  height: 320,
  color: Colors.white,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      const AspectRatio(aspectRatio: 1, child: ColoredBox(color: Colors.grey)),
      const Expanded(child: Align(alignment: Alignment.centerLeft, child: Text('Wine name'))),
      const SizedBox(height: 8),
      const Text('5'),
      const SizedBox(height: 16),
    ],
  ),
)
```

## Domain layer

We need to define a model for which our application would operate in. For lack of a better name, we would call this model `Wine`.
You can paste this snippet preferably at the bottom, so it doesn't get in the way.
The most important things to note is that this is just a simple *Dart* class with five (5) properties, `id`, `imageId`, `name`, `rating` and `year`.
The rest of it is just plumbing for lack of proper data classes in *Dart*.

```dart
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
```

I believe the properties properly describe themselves, so we would move along.

## Home page

In *Flutter*, there are majorly two (2) kinds of widgets, [StatelessWidget](https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html) and [StatefulWidget](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html).
In this case, we would be creating a *StatefulWidget* as we believe our home page to contain some "state" soon enough.
As first step, we are basically just extracting the contents of the `home` property of the `MaterialApp`. Your `HomePage` widget should look like the following.

```dart
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Winery'),
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          width: 240,
          height: 320,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const AspectRatio(aspectRatio: 1, child: ColoredBox(color: Colors.grey)),
              const Expanded(child: Align(alignment: Alignment.centerLeft, child: Text('Wine name'))),
              const SizedBox(height: 8),
              const Text('5'),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
```

Then replace the contents of the `home` property of the `MaterialApp` with the snippet below.
```dart
home: const HomePage()
```

## Datastore

We plan to create a collection of dummy data for the `HomePage` so we can see our domain model `Wine` in action.

First, let's import the required libraries. This goes to the top of the *pad*.

```dart
import 'dart:math';
import 'package:flutter/foundation.dart';
```

Then we would generate a collection aka `List` of `Wine` models. This should be a variable in the `_HomePageState` class.

```dart
final List<Wine> wines = List<Wine>.generate(10, (int index) {
  return Wine(
    id: shortHash(index * 1000),
    imageId: 1 + Random().nextInt(35),
    name: 'Wine $index',
    rating: Random().nextInt(6),
    year: 1200 + index,
  );
});
```

We would get back to this later. Moving on.

## Improving the User Interface

Making reference to the design, it appears we would need to display the `Wine` items in a grid structure.
Thankfully, `Flutter` comes with a full-featured grid builder aptly named [GridView](https://api.flutter.dev/flutter/widgets/GridView-class.html).

With this knowledge, you would replace the contents of `body` in the `Scaffold` with the snippet below.

```dart
GridView.builder(
  padding: const EdgeInsets.all(16),
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    childAspectRatio: 1 / 1.25,
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
  ),
  itemCount: wines.length,
  itemBuilder: (BuildContext context, int index) {
    final Wine wine = wines[index];
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const AspectRatio(aspectRatio: 1, child: ColoredBox(color: Colors.grey)),
          Expanded(child: Align(alignment: Alignment.centerLeft, child: Text(wine.name))),
          const SizedBox(height: 8),
          const Text('5'),
          const SizedBox(height: 16),
        ],
      ),
    );
  },
)
```

If we noticed, our code is beginning to take a "nose-like" shape. For this reason, we are going to shake things up a little by splitting the widgets.
We begin by extracting the component into a separate widget and this time a `StatelessWidget`.

```dart
class WineCard extends StatelessWidget {
  const WineCard({Key? key, required this.wine}) : super(key: key);

  final Wine wine;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const AspectRatio(aspectRatio: 1, child: ColoredBox(color: Colors.grey)),
          Expanded(child: Align(alignment: Alignment.centerLeft, child: Text(wine.name))),
          const SizedBox(height: 8),
          const Text('5'),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
```

Then using it this way in the `GridView`'s `itemBuilder`.
```dart
return WineCard(key: Key(wine.id), wine: wine);
```

Spicing things up a notch, we modify the look of the `WineCard` with a drop shadow, a bit of roundness with some padding for the texts.
Your `WineCard` should look like the snippet below.

```dart
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
          const AspectRatio(aspectRatio: 1, child: ColoredBox(color: Colors.grey)),
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Text('5'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
```

If you have noticed, we somehow have a static `Text('5')` just hanging there. This would be replaced shortly with the star rating earlier promised.
Sadly, there is no widget for this in the framework but due to its versatility, we could also just build our own. I present you the `StarRating` widget.

```dart
class StarRating extends StatelessWidget {
  const StarRating({Key? key, required this.rating}) : super(key: key);

  final int rating;

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
            onPressed: null,
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

With this, we can replace the static `Text('5')` with `StarRating(rating: 5)`.

## More Details

First thing to notice from the design is that we would be using the `AppBar` again on the details page, so we extract it as its own widget.
This time, we extend the `AppBar` widget directly. Yes, you do not always need to extend the `StatelessWidget` and/or `StatefulWidget`.

```dart
class SharedAppBar extends AppBar {
  SharedAppBar({Key? key})
      : super(
          key: key,
          title: const Text('Winery'),
          centerTitle: true,
          elevation: 0,
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
        );
}
```

Next, we scaffold the `DetailsPage` with the customary *"hello world"* and just like the `HomePage` we make a `StatefulWidget`.

```dart
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
      appBar: SharedAppBar(),
      body: const Center(
        child: Text('Hello world'),
      ),
    );
  }
}
```

With our `DetailsPage` sitting pretty, we do have to somehow navigate to it. And again, `Flutter` has a navigation framework baked in so no worries there.
For lack of a better name, its called the [Navigator](https://api.flutter.dev/flutter/dart-html/Navigator-class.html) widget. Before we make use of that though, we need to somehow handle clicking on the `WineCard` widget.
We are in luck as well because the framework also provides us with a tidy [GestureDetector](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html) widget for doing just that.

First, we wrap the `WineCard` in the `itemBuilder` with a `GestureDetector` widget and add an `onTap` callback. Then, use the `Navigator` widget to *"push"* the `DetailsPage`.

```dart
return GestureDetector(
  key: Key(wine.id),
  onTap: () {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => DetailsPage(wine: wine)),
    );
  },
  child: WineCard(wine: wine),
);

```

With that done, we can begin fleshing out the structure of the `DetailsPage`. For now, we keep it simple.

```dart
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
      appBar: SharedAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const AspectRatio(aspectRatio: 1.5, child: ColoredBox(color: Colors.grey)),
            const SizedBox(height: 24),
            Text(widget.wine.name),
            const SizedBox(height: 16),
            Text('${widget.wine.year}'),
            const SizedBox(height: 16),
            StarRating(rating: widget.wine.rating),
          ],
        ),
      ),
    );
  }
}
```

## Pictures speak louder

IIRC we added a certain `imageId` to the `Wine` model, it is about high time we made use of it. Add the snippet below somewhere above the `main` entry point.
We got a random collection of images of wine bottles prepared ahead of time.

```dart
const String imagesApi = 'https://flutter-introductory-workshop.vercel.app/api/images';
```

Next, we replace the grey `ColoredBox`es found in the `WineCard` and `DetailsPage` respectfully with:
```dart
Image.network('$imagesApi/${wine.imageId}')
```
```dart
Image.network('$imagesApi/${widget.wine.imageId}')
```

Just realized one thing missing. There is no interface for the year the wine was produced. For this, we replace the `AspectRatio` widget in the `WineCard` with the following snippet.

```dart
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
)
```

## Round up

All things being equal, you should have a functioning `Flutter` app.
You can compare and even see this in action via this [DartPad](https://dartpad.dev/?id=27b53f2f87ae56cf10037f6e49ad925a)
