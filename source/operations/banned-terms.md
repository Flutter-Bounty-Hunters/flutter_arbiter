---
title: Banned Terms
description: Names you should avoid when programming.
synopsis: Avoiding bad names is as important as using good names. You should avoid these terms when 
  naming your own app or package classes, methods, and properties.
layout: layouts/article.jinja
groupOrder: 2
---
Avoiding ambiguous names in software is as important as choosing meaningful names. The following
is a list of names to avoid in your code.

### Controller 
The term "controller" has a very specific meaning in Flutter development. A
Controller is an object that shares data and control both inside and outside a widget. For example,
Flutter defines `ScrollController`, `AnimationController`, and `TabBarController`. Unless you're
defining an object with a similar purpose, you should avoid the term "controller" so that the term
doesn't become overloaded.

### Helper 
Every piece of code that you write "helps" you to do something. If it didn't, you wouldn't
write it. Calling something a "helper" communicates nothing.

### Utility 
Every piece of code that you write is a "utility". Calling something a "utility"
communicates nothing.

### Manager
All code "manages" things. In general, calling something a "manager" adds no new
information. The only exception to this rule is when the term "manager" is used to describe an
object that owns full authority over some resource. For example, "Bluetooth Manager", "File
System Manager", "Memory Manager".

### Data 
Sometimes a class exists to hold structured data, i.e., a "data structure". While it's
tempting to call that class "data", the word "data" adds nothing. Rather than define `UserData`,
`StockHistoryData`, `PostData`, you should call these things `User`, `StockHistory`, and `Post`,
which communicates the same information with less verbosity.

### Model
Everything in code is a model. Rarely is it useful to add the word "model" to some
other term. "View Model" is the rare exception to this rule. Otherwise, things like `UserModel`,
`StockHistoryModel`, and `PostModel` could simply be called `User`, `StockHistory`, and `Post`.

