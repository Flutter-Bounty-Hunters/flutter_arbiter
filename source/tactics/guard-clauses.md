---
title: Guard Clauses
description: Simplify methods with guard clauses
synopsis: Stop filling methods with deeply nested conditionals with return statements. Use guard
  clauses to handle exceptional conditions and return early so that readers can focus on the important
  details in your methods.
layout: layouts/article.jinja
---
If-statements are a part of life for programmers. However, nested if-statements quickly make
code difficult to read. As you scroll down through nested if-statements, your brain needs to push
and pop conditions for every start and end to a block of code. Guard clauses are a coding tactic
that can help to reduce the number of nested if-statements in your code.

## What is a Guard Clause?
A guard clause is an if-statement that's used to exit code early. 

```dart
void doProtectedAction() {
  if (user == null) {
    // The user isn't signed in.
    return;
  }
  
  if (!user.hasAuthorization) {
    // The user doesn't have authorization to take this action.
    return;
  }
  
  // We now know the user is logged in, and has authorization, so
  // there's no need to think about those details any further.
  // ...
}
```

The example above shows a method that should only be executed for authorized users. Rather
than spread those concerns throughout the method implementation, the method checks those details
up front, and immediately returns, if the conditions aren't meant. As a result, readers can focus
fully on the details of the code that follows, rather than worrying about whether the current
user is signed in, or has authorization.

Use of guard clauses tends to produce code that's easier to read and understand, and code that's
less likely to include bugs related to exceptional conditions.

## Example: A build method
A `build()` method that creates a text message editor, using nested if-statements.

```dart
Widget build(BuildContext context) {
  if (_useCanSendMessage) {
    if (_focusNode.hasFocus) {
      return MessageEditor(
        focusNode: _focusNode,
        editor: _editor,
        onSendPressed: _sendMessage,
      );
    } else {
      return MinimizedMessageEditor(
        hint: "Type a message...",
        onPressed: _openEditor,
      );
    }
  } else {
    return const SizedBox();
  }
}
```

The same `build()` method, using guard clauses:

```dart
Widget build(BuildContext context) {
  if (!_userCanSendMessage) {
    return const SizedBox();
  }
  
  if (!_focusNode.hasFocus) {
    return MinimizedMessageEditor(
      hint: "Type a message...",
      onPressed: _openEditor,
    );
  }
  
  return MessageEditor(
    focusNode: _focusNode,
    editor: _editor,
    onSendPressed: _sendMessage,
  );
}
```

## Example: A long running State method
It's common to define methods in `State` objects that include asynchronous behaviors. Doing so
requires that you check `mounted` after every such call.

The following `State` method uses nested if-statements:

```dart
Future<void> _initializeApp() async {
  await initializeErrorLogger();
  if (mounted) {
    initializeDebugLoggers();
    
    await restoreUser();
    if (mounted) {
      if (User.instance.isSignedIn) {
        Navigator.of(context).replaceWithNamed("home");
      } else {
        Navigator.of(context).replaceWithNamed("sign-in");
      }
    }
  }
}
```

The same asynchronous method with guard clauses:

```dart
Future<void> _initializeApp() async {
  await initializeErrorLogger();
  if (!mounted) {
    return;
  }
  
  initializeDebugLoggers();
    
  await restoreUser();
  if (!mounted) {
    return;
  }
  
  if (User.instance.isSignedIn) {
    Navigator.of(context).replaceWithNamed("home");
  } else {
    Navigator.of(context).replaceWithNamed("sign-in");
  }
}
```
