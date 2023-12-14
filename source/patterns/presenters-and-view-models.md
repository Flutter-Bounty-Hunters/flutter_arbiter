---
title: Presenters and View Models
description: What are presenters and view models in Flutter?
synopsis: Presenters are objects that expose non-UI application behavior to UI widgets. View models
  are data structures that provide properties that are specifically designed for widget rendering.
layout: layouts/article.jinja
header_image: https://firebasestorage.googleapis.com/v0/b/proflutter-45c26.appspot.com/o/canon%2Fpresenters%2Fpresenters_header.png?alt=media&token=88838055-9c72-46ec-a92e-049fb0a8a5cd
---
Your app uses networking, databases, and sensors. Your user interface shouldn't be aware of these details. Leaking integrations into your interface makes testing impossible, prevents product demos, and causes developers to interfere with each others' work. Presenters separate your UI from all other application responsibilities, which facilitates tests, demos, and focused development.
 
> Presenters are an approach to a common problem. They are not a library or a framework. There are no absolute requirements for what a Presenter must do, or not do. The only goal is to separate layout and rendering responsibilities from the rest of the app.

The most important detail about a Presenter is its public interface. The interface of a Presenter is designed to meet the needs of the UI to which it applies. 

Imagine a "contact" screen that displays information about a person, and allows you to start and end a phone call.

The Presenter for the contact screen would reveal the person's contact information, an operation to start a phone call, a status flag to check if a call is in-progress, and an operation to end a phone call:

```dart
abstract class PhoneScreenPresenter with ChangeNotifier {
  Uri get photoUri;
  String get firstName;
  String get lastName;
  PhoneNumber get phoneNumber;
  
  bool get isCallActive;
  Future<void> callPhoneNumber();
  Future<void> hangup();
}
```

Notice that the `PhoneScreenPresenter` only exposes what the contact screen requires. The Presenter doesn't reveal where the contact's information came from, how it might change, or how the call operation is executed.

The concrete version of `PhoneScreenPresenter` might use Firestore to obtain the contact's information, and it might use a community plugin to access the phone's dialing system. But that information isn't public. The UI doesn't care.

The implementation of a Presenter is fully aware of the underlying integrations, but the public interface of a Presenter only serves the needs of the user interface. By limiting the public interface to the minimum information needed for the UI, you ensure that your UI doesn't declare any unnecessary imports or dependencies on non-UI systems. A single mis-placed dependency on `dart:io` will crash your app on the web, and a single mis-placed dependency on `dart:js` might crash your app in a test.

## How to use a Presenter
The easiest way to use a Presenter is to pass a Presenter into the constructor of the corresponding widget.

Assume that you have a screen widget called `PhoneScreen`. `PhoneScreen` requires a Presenter of type `PhoneScreenPresenter`. You have a concrete implementation of `PhoneScreenPresenter` called `DefaultPhoneScreenPresenter`. You might construct your `PhoneScreen` like this:

```dart
MaterialApp(
  routes: {
    'phone-call': (context) => PhoneScreen(
      presenter: DefaultPhoneScreenPresenter(),
    ),
  },
);
```

In the above example, a `PhoneScreen` widget is constructed for the `"phone-call"` route. A `DefaultPhoneScreenPresenter` is instantiated immediately, and passed into the `PhoneScreen`.

This same approach could be taken with `onGenerateRoute`, which would allow you to also accept route arguments.

Instantiating Presenters within a route builder is usually a fine thing to do. However, you may have use-cases where it's exceptionally important to cache the Presenter and avoid creating new instances. If you think this is a problem, you should verify the problem before you add complexity. That said, you can cache a Presenter, and inject it, using your preference for a widget-tree injector.

You might use `Provider` to cache a Presenter:

```dart
MultiProvider(
  providers: [
    Provider<PhoneScreenPresenter>(
      create: (_) => PhoneScreenPresenter(),
    ),
  ],
  child: MaterialApp(
    routes: {
      'phone-call': (context) => PhoneScreen(
        presenter: Provider.of<PhoneScreenPresenter>(
          context, 
          listen: false,
        ),
      ),
    },
  ),
);
```

You could also implement your own `InheritedWidget`, store a static reference, or use a Dart-level dependency injector like `get_it`. Whatever option you choose, make sure that it works well with your testing strategy.

## How to implement a Presenter
Every Presenter has different responsibilities. They don't have much in common. However, you should consider how you plan to deal with a Presenter's dependencies.

First, as with all the code that you write, it's a good idea to inject your Presenter's dependencies in your Presenter's constructor. By injecting dependencies, you leave the door open to test your Presenter implementation, and also to switch the underlying integration later, if you so choose.

In addition to injecting dependencies, you must decide what kind of dependencies to inject. This depends on the size and scope of your app.

### Presenter dependencies in a small app
In a small to medium sized app, Presenters can talk to business rules as well as I/O sources.

![](https://firebasestorage.googleapis.com/v0/b/proflutter-45c26.appspot.com/o/canon%2Fpresenters%2Freference_small-apps.png?alt=media&token=264d95fc-52ed-4fdb-b619-1997a9679210)

For example, in a small app, it's probably fine to directly inject Firestore for data lookup:

```dart
return PhoneScreen(
  presenter: DefaultPhoneScreenPresenter(
    firestore: Firestore.instance,
    phoneDialer: MobilePhonePlugin.instance,
  ),
);
```

Notice that we provide `DefaultPhoneScreenPresenter` with direct access to the Firestore database. This is probably fine for small apps where there are very few business rules that apply across the app.

However, you shouldn't be so permissive about data access in larger apps.

### Presenter dependencies in a large app
In larger apps, especially those with large teams and shared app infrastructure, Presenters should talk only to the business domain. All I/O sources should alter the business domain, which then propagates to Presenters.

![](https://firebasestorage.googleapis.com/v0/b/proflutter-45c26.appspot.com/o/canon%2Fpresenters%2Freference_large-apps.png?alt=media&token=ff58ff1b-ea39-45fd-9992-d59499dba8ce)

Let's adjust the previous Presenter example for a larger app:

```dart
return PhoneScreen(
  presenter: DefaultPhoneScreenPresenter(
    contactRepository: ContactRepository.instance,
    phoneDialer: MobilePhonePlugin.instance,
  ),
);
```

Notice that we've replaced the `Firestore` reference with a `ContactRepository` reference. The `ContactRepository` hides the source of the contact information, as well as the storage format for that information. Hiding these details greatly restricts what developers can do with, and to, contact information. For example, with `Firestore` it's possible for the `DefaultPhoneScreenPresenter` to delete the entire contact phone book. On the other hand, the `ContactRepository` API probably prevents any content deletion at all.

When working on a large project with many developers, consider abstracting information sources, data formats, and access policies. This will prevent costly data integrity issues.

## Avoiding a BuildContext in a Presenter
You should try to avoid the use of a `BuildContext` within a Presenter.

A `BuildContext` is often used to obtain dependencies, e.g., `Navigator.of(context)`, `Theme.of(context)`, `MediaQuery.of(context)`. It may be tempting to use a `BuildContext` within a Presenter, but this introduces a couple of issues.

To illustrate this issue, let's assume that when a phone call ends, the `PhoneScreen` should `pop()` off the back-stack and navigate to the previous route. Somewhere in this interaction, a call must be made to `Navigator.of(context).pop()`. Let's look at how **not** to handle this.

### Keeping the Presenter in-sync with its widget
A `BuildContext` refers to a location in the widget tree at a specific moment in time. If you cache a `BuildContext` in a Presenter, then the Presenter might access the `BuildContext` when it's no longer valid.

For example, injecting a `BuildContext` in a Presenter's constructor is almost guaranteed to result in bugs:

```dart
'phone-call': (context) => PhoneScreen(
  presenter: DefaultPhoneScreenPresenter(
    context: context,
  ),
);
```
 
By the time this given `context` is used by `DefaultPhoneScreenPresenter`, that `context` may no longer exist in the widget tree.

If you can't inject a `BuildContext` in the Presenter's constructor, you might try to inject one in a Presenter method.

### Eroding the encapsulation boundary
A Presenter is supposed to meet the needs of it's widget, but the widget isn't supposed to know what the Presenter will do. You may have multiple implementations of the same Presenter that you use in different circumstances. If you pass a `BuildContext` into a Presenter method, you are publicly indicating that you expect the Presenter to use the `BuildContext`:

```dart
FloatingActionButton(
  onPressed: () {
    widget.presenter.hangup(context),
  },
  child: //...
),
```

Notice in this example that `hangup()` takes a `BuildContext`. Technically, you can do this. But this approach means that your abstract interface for `PhoneScreenPresenter` always requires a `BuildContext` for `hangup()`. Why is that? Why would every possible implementation of `hangup()` require a `BuildContext`? Your fake implementations in your tests definitely don't need a `BuildContext`.

The problem with this approach is that the widget is implying too much knowledge about what the Presenter is going to do. The widget shouldn't know that the Presenter needs a `BuildContext`, because the widget shouldn't assume any of the implementation details about the Presenter.

### How to avoid injecting a BuildContext
Avoid injecting a `BuildContext` into a Presenter by instead injecting a callback that, itself, can access a `BuildContext`.

Imagine that the `DefaultPhoneScreenPresenter` implements `hangup()` as follows:

```dart
class DefaultPhoneScreenPresenter with ChangeNotifier implements PhoneScreenPresenter {
  DefaultPhoneScreenPresenter({
    required VoidCallback popNavigator,
  }) : _popNavigator = popNavigator;
  
  final VoidCallback _popNavigator;
  
  Future<async> hangup() async {
    await _phoneDialer.hangup();
    
    // Now that the hangup is complete, execute
    // the _popNavigator callback.
    _popNavigator();
  }
}
```

Notice that the `DefaultPhoneScreenPresenter` invokes a callback called `_popNavigator()`, rather than directly access a `Navigator`. The `popNavigator` argument is provided by whatever instantiates the `DefaultPhoneScreenPresenter`:

```dart
'phone-call': (context) => PhoneScreen(
  presenter: DefaultPhoneScreenPresenter(
    popNavigator: () {
      Navigator.of(context).pop();
    },
  ),
);
```

`DefaultPhoneScreenPresenter` causes the desired navigation after hanging up the phone, without requiring a direct reference to a `BuildContext`.

## Testing
Testing with Presenters can be broken into two categories: testing widgets that use Presenters, and testing individual Presenter implementations.

Typically, Presenter implementations depend upon platform capabilities, like networking, local databases, BLE, and other tightly integrated subsystems. These integrations are difficult or impossible to test, and testing them is often pointless. Therefore, you typically won't test Presenter implementations. But you should absolutely test widgets that use Presenters.

When it comes to testing widgets that use Presenters, you have all the standard tools at your disposal: interaction tests, golden tests, and integration tests. Understanding how to write tests in Flutter is a topic for a dedicated guide. The only thing you need to know about Presenters is that you can implement fake Presenters in your test suites to fully exercise the widget that uses the Presenter.

Consider the "contact" screen that we've worked with in this article. Let's assume that when a phone call is active, the call button on the screen is disabled. We might test that UI behavior like this:

```dart
class FakePhoneScreenPresenter with ChangeNotifier implements PhoneScreenPresenter {
  final Uri photoUri = Uri.parse('http://fake.com');
  final String firstName = 'John';
  final String lastName = 'Smith';
  final PhoneNumber phoneNumber = PhoneNumber.parse('123-456-7890');
  
  // This is the only line that matters for this test.
  final bool isCallActive = true;
  
  Future<void> callPhoneNumber() async {}
  Future<void> hangup() async {}
}

test(
  'call button is disabled during a phone call',
  (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PhoneScreen(
          // Inject our fake Presenter.
          presenter: FakePhoneScreenPresenter(),
        ),
      ),
    );
    
    // Just in case there are any transition 
    // animations, let's pump and settle before 
    // we check the condition.
    await tester.pumpAndSettle();
    
    // Confirm that the FAB call button is disabled.
    expect(
      tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      ).onPressed,
      isNull,
    );
  },
);
```

If you're writing many tests for a widget that uses a Presenter, you might implement a fake Presenter that supports a variety of hard-coded configurations. Then, you can initialize the fake Presenter however you'd like for each of your tests. Make sure that you don't introduce so much complexity in your fake Presenter that you end up with a new source of bugs.

`Mockito` is a popular tool for faking and mocking Dart classes. Unfortunately, the tool became far less expedient when it was migrated to null-safety. But, you might still find it useful.