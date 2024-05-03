---
title: Developer logs
description: Avoid the print statement firehose with a logger.
synopsis: The most popular debug tool is print statements littered through code. They get
  the job done, but they can expose sensitive data, cause performance problems, and fill
  your terminal with noise that hides the important details. Learn how to fix these issues
  with loggers.
layout: layouts/article.jinja
groupOrder: 12
redirectFrom: operations/developer-logs
---
The first thing a developer does when things go wrong is add a `print` statement somewhere
in the code and then re-run the app. This approach tends to work in the moment, but if you're
not careful, you'll accumulate lots of random `print` statements throughout your codebase.
Those `print` statements will turn into noise for the team, they might expose sensitive data,
and they could even interfere with performance. You can use loggers to avoid these problems.

## What is a logger?
A logger is essentially a `print` statement with more control.

You can turn a logger on and off, so you get the log messages when you want them, and don't
get those log messages when you don't. This means you can turn off all of your loggers in
production builds, which ensures that sensitive data is NOT written to output sources on end-user
devices. Turning loggers off in production builds also ensures that your log statements
don't cause performance problems when it matters.

You can send log messages at different levels, then you can filter out all logs below
a given level. For example, sometimes you only care about errors and warnings. Other times
you might care about errors, warnings, info, traces, etc. With loggers, you can configure
these levels during development to dig into the problem before you.

## Use the logging package
The Dart team publishes a package called [`logging`](https://pub.dev/packages/logging).
The `logging` package is a simple but useful tool for creating and using loggers. If you're
not already used to logging messages in Dart and Flutter, then I recommend using the
`logging` package for a while. Once you're in the habit of using `Logger`s instead of
`print`, you can investigate more sophisticated logging packages that might offer further
tools for your use-cases.

### Get started with the logging package
To help you get started with the `logging` package, the following `logger.dart` file
can be dropped into your codebase and used as a starting point.

```dart
// ignore_for_file: avoid_print
import 'package:logging/logging.dart';

/// Send log output from all loggers, at or above the given [level], to the terminal.
void initAllLogs(Level level) {
  initLoggers(level, {Logger.root});
}

/// Send output from the given [loggers], at or above the given [level], to the terminal.
void initLoggers(Level level, Set<Logger> loggers) {
  hierarchicalLoggingEnabled = true;

  for (final logger in loggers) {
    if (!_activeLoggers.contains(logger)) {
      print('Initializing logger: ${logger.name}');
      logger
        ..level = level
        ..onRecord.listen(_printLog);

      _activeLoggers.add(logger);
    } else {
      // The logger is already active. Adjust the log level as desired.
      logger.level = level;
    }
  }
}

/// Returns `true` if the given [logger] is currently logging, or
/// `false` otherwise.
///
/// Generally, developers should call loggers, regardless of whether
/// a given logger is active. However, sometimes you may want to log
/// information that's costly to compute. In such a case, you can
/// choose to compute the expensive information only if the given
/// logger will actually log the information.
bool isLogActive(Logger logger) {
  return _activeLoggers.contains(logger);
}

/// Stop the given [loggers] from sending any output to the terminal.
void deactivateLoggers(Set<Logger> loggers) {
  for (final logger in loggers) {
    if (_activeLoggers.contains(logger)) {
      print('Deactivating logger: ${logger.name}');
      logger.clearListeners();

      _activeLoggers.remove(logger);
    }
  }
}

void _printLog(LogRecord record) {
  print(
    '(${record.time.second}.${record.time.millisecond.toString().padLeft(3, '0')}) ${record.loggerName} > ${record.level.name}: ${record.message}',
  );
}

final _activeLoggers = <Logger>{};
```

With this file added to your project, you can accomplish various logging goals.

Activate all logs at a given level:

```dart
void main() {
  initAllLogs(Level.FINE);
}
```

Activate only the logs you care about:

```dart
void main() {
  initLoggers(
    Level.INFO, {
    appInitLog,
    authLog,
    networkLog,
  });
}
```

Activate the logs only in debug mode:

```dart
void main() {
  if (kDebugMode) {
    initAllLogs(Level.FINE);
  }
}
```

The `logging` package lets you instantiate `Logger`s wherever you'd like. You can define them
all together, or separately.

```dart
// logger.dart
// Define loggers together
final appInitLog = Logger("app-init");
final authLog = Logger("auth");
final networkLog = Logger("network");

// --- or define them separately ---

// app.dart
final appInitLog = Logger("app-init");

// auth.dart
final authLog = Logger("auth");

// network_client.dart
final networkLog = Logger("network");
```

The `logging` package also supports hierarchical `Logger`s based on their name. This makes
it easy to enable an entire set of related `Logger`s.

```dart
final authLog = Logger("auth");
final authCacheLog = Logger("auth.cache");
final googleAuthLog = Logger("auth.google");
final appleAuthLog = Logger("auth.apple");

void main() {
  if (kDebugMode) {
    // Enabling the authLog automatically enables all sub-logs, including
    // "auth.cache", "auth.google", and "auth.apple".
    initLoggers(Level.INFO, {authLog});
  }
}
```

## What to log
Choosing what to log is an art and a science. There's no universal answer. You should use
your knowledge of your development process to decide where it makes sense.

First, you shouldn't convert all of your debugging `print` statements into logs. When
you're actively debugging your code, you'll `print` a lot of information that's only
relevant to what you're doing right now. Once you fix your bug, you should delete most
of those `print` statements entirely. However, along the way, you might find some places
in the code where the team could use logs on a regular basis.

For example, it might be a good idea to log information from each of your network calls:

```dart
class MyNetworkClient {
  Future<void> post(String url, String? body) async {
    try {
      networkLog.info("POST: $url\nBody: $body");
      // ...do the network call...
    } catch (exception, stacktrace) {
      networkLog.warn("Failed to POST to $url with body $body");
      networkLog.warn("$exception");
      networkLog.warn("$stacktrace");
      rethrow;
    }
  }
}
```

Similarly, you might log requests, events, and results for areas like app initialization,
user authentication, routing, and database communication.

Now go log stuff. Start simple with the `logging` package. Start humble with just a few
`Logger`s. Then spread out as needed.