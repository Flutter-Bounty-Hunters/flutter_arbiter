---
title: Consistent code ordering
description: Order your code consistently for easy readability.
synopsis: Reading code quickly depends upon consistency in coding practices. Apply these code
  ordering policies throughout your code for faster reading and easier review.
layout: layouts/article.jinja
groupOrder: 11
---
The best way to help developers on your team read code quickly is to establish consistent practices.
When reviewing code that follows consistent practices, a developer can literally review code as
quickly as he can scroll down the change list. This is because repeated behaviors and approaches
have already been reviewed. The reviewer already knows the why/how/where of consistent practices.

One area to achieve consistency is in the ordering of repeated code elements. Here are some order
rules for you to employ throughout your codebase.

## High level to low level
Most code is read by developers who didn't write it. When reading code that you didn't write, you're
not yet aware of what code is written. You don't know how the problem is broken down.  In fact,
you may not yet be aware of the problems that the code solves. 

To help readers learn as much about your code as quickly as possible, write it from high level to
low level.

The following example shows an entrypoint file that's written from high level to low level.

```dart
void main() {
  runApp(MyFlutterApp);
}

class MyFlutterApp extends StatelessWidget {
  const MyFlutterApp();
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: MyPage(),
      ),
    );
  }
}

class MyPage extends StatefulWidget {/* */}
```

The same principle applies between methods in a class. When Method A calls Method B, Method A should
be defined before Method B. When Method A calls multiple methods, like Method B and Method C, those
other methods should be defined in the same order that they're called.

```dart
Future<void> generateSite() async {
  _clearDestination();
  await _loadPagesAndAssets();
  _indexPages();
  await _renderPages();
  await _writePagesAndAssetsToFiles();
}

void _clearDestination() {
  final destination = _findDestinationDirectory();
  // ...
}

Future<void> _loadPagesAndAssets() {/* */}

void _indexPages() {/* */}

Future<void> _renderPages() {/* */}

Future<void> _writePagesAndAssetsToFiles() {
  // ...
  final destination = _findDestinationDirectory();
  // ...
}

Directory _findDestinationDirectory() {/* */};
```

## Static members above instance members
Static members belong to the class, and instance members belong to individual instantiations of the
class. These are different types of objects, used for different purposes. Keep your static members
at the top of the class and place all instance members below them.

```dart
class UserSession with ChangeNotifier {
  static UserSession? _instance;
  static UserSession get instance {
    _instance ??= UserSession._();
    return _instance!;
  }
  
  UserSession._();
  
  bool isAnonymous => _user == null;
  
  User? get user => _user;
  User? _user;
  
  Future<User?> signIn() {/* */}
  
  Future<void> signOut() {/* */}
}
```

## Factories, then named constructors, then the default constructor
Factory constructors use regular constructors internally. Following the [high level to low level policy](#high-level-to-low-level),
factory constructors should appear above other constructors.

Named constructors, representing specialized versions of the default constructor, should be declared
above the default constructor.

```dart
class Document {
  factory Document.fromMarkdown(Strig markdown) {/*...*/}
  
  Document.withSingleParagraph(String paragraph) : nodes = [/*...*/];
  
  Document(this.nodes);
}
```

## Properties below constructors
As per Dart style guidelines, declare properties below constructors.

```dart
class MyClass {
  MyClass.named();
  
  MyClass();
  
  final String property1;
  final double property2;
  final bool property3;
}
```

## Stateful widget methods
Stateful widgets accumulate quite a few responsibilities. They have properties, lifecycle methods,
interaction methods, and build methods. You should define them in that order. Additionally, you
should define lifecycle methods roughly in the order that they are called, so that the reader can
quickly observe lifecycle changes in the order that they'll happen at runtime.

```dart
class _MyWidgetState extends State<MyWidget> {
  late final AnimationController _animationController;
  User? _user;
  
  @override
  void initState() {/* */}
  
  @override
  void didChangeDependencies() {/* */}

  @override
  void didUpdateWidget(MyWidget) {/* */}

  @override
  void dispose() {/* */}
  
  void _onUserLoaded() {/* */}

  void _onButtonPressed() {/* */}

  @override
  void build() {/* */}
}
```

## Private build methods below public build method
Long widget trees are almost impossible to review. You shouldn't write long widget trees. There are
two ways to break up a long widget tree. You can extract entirely new widgets, but this moves the
extracted code further away from where you need it. Or, you can decompose a single build method into
multiple build methods within the same `State` object.

In general, you should prefer decomposing one build method into multiple build methods so that you
avoid long convoluted trees, but you also keep the relevant code close to where it's used.

When you breakout smaller build methods, those build methods should be private, they should be
named effectively, and they should appear below the public `build()` method, roughly in the order
that they are called.

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: _buildAppBar(),
    body: _buildContent(),
    drawer: _buildDrawer(),
  );
}

PreferredSizeWidget _buildAppBar() {/* */}

Widget _buildContent() {/* */}

Widget _buildDrawer() {/* */}
```