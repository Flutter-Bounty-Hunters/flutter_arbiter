---
title: Custom Matchers
description: How to write custom Matchers for tests
synopsis: When tests fail, you have to find the root cause to fix them. A helpful way to find the
  root cause is with descriptive Matchers that understand your data structures. Learn how to create
  your own.
layout: layouts/article.jinja
---
If you've ever written a Dart test, widget test, or integration test, you've used `Matcher`s. Writing
custom `Matcher`s is a bit of a super power, but the process is terribly documented. This guide explains
what a `Matcher` does, how to create your own, and why you might want to.

## What is a `Matcher`?
A `Matcher` is an object that checks for a desired result, typically used within a call to `expect()`.

Let's look at a few examples.

```dart
// Use the "equals()" Matcher to ensure two Strings are the same.
final myString = "Hello, World!";
expect(myString, equals("Hello, World!"));

// Use the "isNull" Matcher to ensure our variable is null.
final myNull = null;
expect(myNull, isNull);

// Use the "isA" Matcher to ensure our render object is a RenderBox.
final myRenderObject = context.findRenderObject;
expect(myRenderObject, isA<RenderBox>());

// Use the "findsOneWidget" Matcher to ensure the "buttonFinder" found
// exactly one ElevatedButton.
final buttonFinder = find.byType(ElevatedButton);
expect(buttonFinder, findsOneWidget);
```

When using the `expect()` function, an "actual" value is given to the `Matcher`. The `Matcher`
internally compares that "actual" value against whatever details the `Matcher` expects to be true.
If the `Matcher`'s conditions are met, then `expect()` completes without issue. However, if any of
the conditions inside the `Matcher` fail, then the `expect()` call complains and causes your test
to be reported as a failure.

Let's look at some examples of failure messages that come from `Matchers`.

Failing test:
```dart
expect("This is one String", equals("This is another String"));
```

The above expectation fails with the following message. Notice how the error message helps you
identify exactly where things went wrong with the equality.
```
  Expected: 'This is another String'
    Actual: 'This is one String'
     Which: is different.
            Expected: This is another St ...
              Actual: This is one String ...
                              ^
             Differ at offset 8
```

Failing test #2:
```dart
expect("A String", isA<RenderBox>());
```

Test failure message:
```
  Expected: <Instance of 'RenderBox'>
    Actual: 'A String'
     Which: is not an instance of 'RenderBox'
```

Failing test #3:
```dart
await tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: Column(
        children: [
          ElevatedButton(child: Text("one"), onPressed: () {}),
          ElevatedButton(child: Text("two"), onPressed: () {}),
        ],
      ),
    ),
  ),
);

expect(find.byType(ElevatedButton), findsOne);
```

Test failure message:
```
Expected: exactly one matching candidate
  Actual: _TypeWidgetFinder:<Found 2 widgets with type "ElevatedButton": [
            ElevatedButton(dependencies: [MediaQuery, _InheritedTheme,
_LocalizationsScope-[GlobalKey#f7ff0]], state: _ButtonStyleState#abf5d),
            ElevatedButton(dependencies: [MediaQuery, _InheritedTheme,
_LocalizationsScope-[GlobalKey#f7ff0]], state: _ButtonStyleState#cb540),
          ]>
   Which: is too many

```

Every `Matcher` has its own unique way of describing what it expected versus what it actually
found. These descriptions help you quickly root cause the problem and get it fixed.

## Why you might create a custom `Matcher`
There are dozens of `Matcher`s that ship with Dart and Flutter. With so many pre-programmed `Matcher`s,
why would you ever need to create your own?

A `Matcher` tells you \*why\* an expectation failed, and that "why" is very useful. For example, 
you might have a data structure in your app that you need to check in your tests. If the data structure 
is reasonably complicated then it's easy to accidentally break your code. When you break your code, 
a test will fail. The test will say that your actual data structure doesn't match your expected data 
structure. But where is the mismatch? What exactly changed? This is where a custom `Matcher` becomes 
useful.

Let's look at a real example where a custom `Matcher` helped.

### Super Editor Case Study
In [Super Editor](https://supereditor.dev) we have thousands of tests to verify that user interactions
result in the expected changes to a document. For example, when the user types a few characters, those
characters are actually inserted into the document. When the user taps in the middle of a word, the caret
is placed in the middle of the word. Etc.

Many of the tests in Super Editor have expectations that look at very small pieces of data, so those
tests don't require any custom `Matcher`s. However, there are also some tests in Super Editor where
we want to verify the entire document. We want to verify every header, paragraph, list item, and image.
This is one of those complicated data structures mentioned earlier. There are dozens of ways that two
Super Editor documents might be different. So when a test fails, what exactly changed? What's the
mismatch?

To help us fix broken tests more quickly, we created a custom `Matcher` that compares an actual
Super Editor document with an expected Super Editor document and tells us where they diverge.

For example, here's an abbreviated version of a real Super Editor test that uses the custom
`Matcher`.
```dart
testWidgets("writes a document with multiple types of content", (tester) async {
  // Configure and render an empty document.
  final testDocContext = await tester //
      .createDocument()
      .withSingleEmptyParagraph()
      .forDesktop()
      .withInputSource(TextInputSource.keyboard)
      .pump();

  // Put the caret in the document.
  await tester.placeCaretInParagraph("1", 0);

  // Type a paragraph.
  await tester.typeKeyboardText("This is the first paragraph of the document.");
  await tester.pressEnter();

  // Type a blockquote.
  await tester.typeKeyboardText("> This is a blockquote.");
  await tester.pressEnter();
  // Many more user behaviors...

  // Compare the actual document the user created compared to the document
  // we expected the user to create.
  expect(
    testDocContext.findEditContext().document,
    documentEquivalentTo(_expectedDocument), // <- custom Matcher
  );
});
```

Any number of things could go wrong in this test. Without a custom `Matcher` a developer would
be taking stabs in the dark to fix this test.

With the custom document `Matcher`, let's see what a failing test message might look like.

```
The following TestFailure was thrown running a test:
Expected: given Document has equivalent content to expected Document
  Actual: <Instance of 'MutableDocument'>
   Which: expected 12 document nodes but found 11
          ┌──────────────────┬──────────────────┬─────────────────┐
          │     Expected     │      Actual      │   Difference    │
          ┝━━━━━━━━━━━━━━━━━━┿━━━━━━━━━━━━━━━━━━┿━━━━━━━━━━━━━━━━━┥
          │ParagraphNode     │ParagraphNode     │                 │
          ├──────────────────┼──────────────────┼─────────────────┤
          │ParagraphNode     │ParagraphNode     │Different Content│
          ├──────────────────┼──────────────────┼─────────────────┤
          │ParagraphNode     │ParagraphNode     │                 │
          ├──────────────────┼──────────────────┼─────────────────┤
          │ListItemNode      │ListItemNode      │                 │
          ├──────────────────┼──────────────────┼─────────────────┤
          │ListItemNode      │ListItemNode      │                 │
          ├──────────────────┼──────────────────┼─────────────────┤
          │ListItemNode      │ParagraphNode     │Wrong Type       │
          ├──────────────────┼──────────────────┼─────────────────┤
          │ParagraphNode     │ListItemNode      │Wrong Type       │
          ├──────────────────┼──────────────────┼─────────────────┤
          │ListItemNode      │ListItemNode      │Different Content│
          ├──────────────────┼──────────────────┼─────────────────┤
          │ListItemNode      │ListItemNode      │Different Content│
          ├──────────────────┼──────────────────┼─────────────────┤
          │ListItemNode      │HorizontalRuleNode│Wrong Type       │
          ├──────────────────┼──────────────────┼─────────────────┤
          │HorizontalRuleNode│ParagraphNode     │Wrong Type       │
          ├──────────────────┼──────────────────┼─────────────────┤
          │ParagraphNode     │NA                │Missing Node     │
          └──────────────────┴──────────────────┴─────────────────┘
```

The custom `Matcher` tells us that it expected 12 document nodes but only found 11. Right off
the bat we know that the actual document is too short. It's missing something.

To further help the developer figure out where things are going wrong, the custom `Matcher`
prints out a node-by-node comparison of the expected and actual documents.

If you look closely at the document comparison, you'll first notice that there's an additional
problem with node #2. All the nodes around that one are fine, but that node says it has the
wrong content. That's to be expected, because I intentionally introduced a typo, changing
"blockquote" to "bolckquote". The custom `Matcher` could be further improved by adding content
comparisons to each cell in the table, but at least we know where to look.

The second problem you'll notice is that everything is going well until node #6. At that
point each document has a different type of node. The expected document has a list item, but
the real document has a paragraph. If you look at all the nodes that follow, we can see that
except for the missing list item, all remaining nodes have matching types. This means that
the problem is a single missing list item node. This is also expected, because I removed the
code that typed the 3rd list item.

Fixing the typo in "blockquote" and adding back the code to create the list item returns the
test to a passing state.

Imagine debugging these issues if the test simply said:

```
Expected: Document
  Actual: Document
```

## How to create a custom `Matcher`
A `Matcher` has two primary jobs:

 * Check one or more expected conditions against a provided value.
 * Describe any mismatch that's found.

Implementing a custom `Matcher` means implementing these behaviors.

The following is a skeleton starting point for implementing a new `Matcher`.

```dart
class MyMatcher extends Matcher {
  @override
  Description describe(Description description) {
    // TODO: Describe what this Matcher wants to match.
    // Example: The equals Matcher says the following when it expects
    //          the String "This is another String":
    //
    // "Expected: 'This is another String'"
  }
  
  @override
  bool matches(dynamic item, Map matchState) {
    // TODO: Decide whether this Matcher passes or fails.
  }
  
  @override
  Description describeMismatch(dynamic item, Description mismatchDescription, Map matchState, bool verbose) {
    // TODO: Describe the mismatch that was found in `matches()`.
    // Example: The equals Matcher says the following when expecting "This is
    //          a String" but gets "This is another String":
    //
    // is different.
    // Expected: This is another St ...
    //   Actual: This is one String ...
    //                   ^
    // Differ at offset 8
  }
}
```

Let's implement a simple example that shows you how to handle each `Matcher` responsibility.
Imagine that your code configures a lot of HTTP requests, so you decide to write a suite of
tests that verify the HTTP requests that you configure. When you compare your expected HTTP
requests to your actual HTTP requests, your failing tests will say something like the following.

```
Expected: Request
  Actual: Request
```

By default, the only information you get in test failures is a combination of object types,
and maybe the output from `toString()`. Let's write a custom `Matcher` that compares HTTP
requests while providing useful output.

First, describe what the `Matcher` is trying to match.

```dart
class HttpRequestMatcher extends Matcher {
  const HttpRequestMatcher(this.expected);
  
  final Request expected;
  
  @override
  Description describe(Description description) {
    description.add("A ${expected.method} HTTP Request");
  }
}
```

Given the above `describe()` method, when a test fails, the first line of the failure will look
like the following.

```
The following TestFailure was thrown running a test:
Expected: A GET HTTP Request
```

You could provide more information in the first line, if desired, but keep in mind that you'll have
a chance to provide much more information when you describe the mismatch.

The next step is to compare the actual `item` with the `expected` value and collect info about anything
that doesn't match. A good first step is to make sure the `item` is the right type of object. If not,
exit early. If it is, then move on to inspecting individual properties.

```dart
class HttpRequestMatcher extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Request) {
      // The actual item is the wrong type. Return `false` immediately
      // and handle the messaging in `describeMismatch`.
      return false;
    }
    
    // Check each property that we care about for request equality.
    // For any property that doesn't match, store the mismatch so
    // we can describe it later.
    //
    // For this example we'll pick a few properties. In a real Matcher
    // you would probably check everything, including a deep inspection
    // of the `bodyFields` `Map`.
    if (item.method != expected.method) {
      matchState["method"] = {
        "expected": expected.method,
        "actual": item.method,
      };
    }
    if (item.url != expected.url) {
      matchState["url"] = {
        "expected": expected.url,
        "actual": item.url,
      };
    }
    if (item.body != expected.body) {
      matchState["body"] = {
        "expected": expected.body,
        "actual": item.body,
      };
    }
    
    if (matchState.isNotEmpty) {
      // We found mismatches. The two values don't match.
      return false;
    }
    
    // The two requests are the same, at least as far as we care.
    return true;
  }
}
```

After identifying the mismatch, it's time to write that mismatch in `describeMismatch()`, which
determines what the developer sees when the expectation fails.

```dart
class HttpRequestMatcher extends Matcher {
  @override
  Description describeMismatch(dynamic item, Description mismatchDescription, Map matchState, bool verbose) {
    // Both `item` and `matchState` are the same objects we were given in `matches()`.
    // We need to write our desired messages to `mismatchDescription`.
    // You can ignore `verbose` - it's meant for specialized use-cases.
    
    // First, handle the case where the actual item has the wrong type.
    if (item is! Request) {
      mismatchDescription.add("Expected a Request. The actual type is: ${item.runtimeType}");
      return mismatchDescription;
    }

    mismatchDescription.add("is different");
    if (matchState.containsKey("method")) {
      // The methods don't match.
      mismatchDescription.add("\n\nExpected method: ${matchState["method"]["expected"]}");
      mismatchDescription.add("\nActual method: ${matchState["method"]["actual"]}");
    }
    if (matchState.containsKey("url")) {
      // The URLs don't match.
      mismatchDescription.add("\n\nExpected url: ${matchState["url"]["expected"]}");
      mismatchDescription.add("\nActual url: ${matchState["url"]["actual"]}");
    }
    if (matchState.containsKey("body")) {
      // The bodies don't match.
      mismatchDescription.add("\n\nExpected body: ${matchState["body"]["expected"]}");
      mismatchDescription.add("\nActual body: ${matchState["body"]["actual"]}");
    }
    
    return mismatchDescription;
  }
}
```

That's all the `Matcher` needs. Let's run a failing test to ensure that each of our compared
properties are displayed in test failure output.

Test that fails with completely different data:
```dart
expect(
  Request(
    "POST",
    Uri.parse("https://flutterarbiter.com"),
  )..body = "Hello, world!", 
  HttpRequestMatcher(
    Request(
      "GET", 
      Uri.parse("http://google.com")
    )..body = "Hello, planet!",
  ),
);
```

Test failure output:
```
Expected: A GET HTTP Request
  Actual: Request:<POST https://flutterarbiter.com>
   Which: is different

          Expected method: GET
          Actual method: POST

          Expected url: http://google.com
          Actual url: https://flutterarbiter.com

          Expected body: Hello, planet!
          Actual body: Hello, world!
```

What about when some of the data matches, and some of the data doesn't match?

Test that fails with partial data mismatch:
```dart
expect(
  Request(
    "GET",
    Uri.parse("https://flutterarbiter.com"),
  )..body = "Hello, world!", 
  HttpRequestMatcher(
    Request(
      "GET", 
      Uri.parse("http://google.com")
    )..body = "Hello, world!",
  ),
);
```

Test failure output:
```
Expected: A GET HTTP Request
  Actual: Request:<GET https://flutterarbiter.com>
   Which: is different

          Expected url: http://google.com
          Actual url: https://flutterarbiter.com
```

The `Matcher` successfully kept out the pieces of data that matched, and told us about the data
that doesn't match.

What if we try to match against something that isn't a `Request`?

```dart
expect(
  "Hello, world!", 
  HttpRequestMatcher(
    Request(
      "GET", 
      Uri.parse("https://flutterarbiter.com")
    )..body = "Hello, world!",
  ),
);
```

Test failure output:
```
Expected: A GET HTTP Request
    Actual: 'Hello, world!'
     Which: Expected a Request. The actual type is: String
```

Finally, let's make sure the test passes when it's supposed to. What happens when we match identical
`Request`s?

```dart
expect(
  Request(
    "GET",
    Uri.parse("https://flutterarbiter.com"),
  )..body = "Hello, world!", 
  HttpRequestMatcher(
    Request(
      "GET", 
      Uri.parse("https://flutterarbiter.com")
    )..body = "Hello, world!",
  ),
);
```

Passing test output:
```
00:00 +1: All tests passed!
```

Lastly, there's an optional final step. You may have noticed that our custom `Matcher` is
instantiated as an object every time we use it, e.g., `HttpRequestMatcher()`. And you may
have noticed that typically in Flutter the `Matcher` is called as a function, e.g.,
`equals()`, `isA()`, etc.

The way Flutter provides functions is by creating functions that return `Matcher`s. In
other words, the instantiation happens inside of the function. For example, this is the
implementation of `isA()`:

```dart
TypeMatcher<T> isA<T>() => TypeMatcher<T>();
```

If desired, we can achieve the same effect by defining a global function the same way
as Flutter. For example:

```dart
// Define a global method that creates the matcher.
HttpRequestMatcher equalsRequest(Request expected) => HttpRequestMatcher(expected);

// Then use the method in your tests:
test("request test", () {
  expect(
    myRequest,
    equalsRequest(expectedRequest),
  );
});
```

And that's a wrap! You now know how to define custom `Matcher`s so that your failing tests can
tell you exactly what's wrong with your expected output.