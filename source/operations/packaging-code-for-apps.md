---
title: Packaging code for apps
description: Directories and files to create for your app.
synopsis: Code has to go somewhere. Learn how to breakdown directories and files in an effective way.
layout: layouts/article.jinja
groupOrder: 10
---
To understand the importance of where you place your code, consider daily operations within a
development team (even a small team). When you begin work on a ticket, you need to locate the code
that you'll extend or alter. When your team member requests your review on a PR, you'll need to
figure out how all the code changes in that PR relate to one another. When you and your team members
start work every day, you're altering a shared codebase, which means you might make conflicting
changes to the code that require extra effort to resolve.

For all of these reasons, you should package your app code in a way that keeps related code close
together, and unrelated code further apart. Developers starting a new ticket will quickly find the
relevant code. PR reviewers will easily recognize the relationship between changed files. And the
team will operate with few, if any, merge conflicts.

## A bundle of features and infrastructure
At a high level, an app is a bundle of features, which are backed by some amount of infrastructure
that's shared across features. Breakdown your app package into those two groups.

```
/lib
  /infrastructure
  /features
```

### Features
A feature is a customer-centric behavior within the app. Each feature deserves a directory and at
least one file within your `/lib/features` directory. A photo-based social media app might breakdown
features in the following manner.

```
/lib
  /features
    /feed
    /home
    /messaging
    /posting
    /profile
    /search
    /sign-in
    /sign-up
```

When multiple features are closely related, those features can be further bundled together.

```
/lib
  /features
    /feed
      /algorithmic
      /search
    /home
    /messaging
    /posting
    /user
      /profile
      /sign-in
      /sign-up
```

### Infrastructure
Infrastructure refers to code that serves two or more features. Infrastructure code is bundled
separately from features because it doesn't map one-to-one with any particular feature. You don't
want code within the `/posting` feature used by the `/messaging` feature - that would prevent the
development gains that we seek with code packaging.

The type of code that qualifies as infrastructure can vary greatly. It includes highly technical
things like networking and database access. But it might also include business-centric things like
subscription entitlements, as well as design-oriented concerns such as theming.

A photo-based social media app might breakdown infrastructure in the following manner.

```
/lib
  /infrastructure
    /authentication
      /gram_authentication.dart
      /google_authentication.dart
      /apple_authentication.dart
    /databases
      /realm.dart
    /photo_filters
    /networking
      /network_client.dart
    /ui_toolkit
      /buttons.dart
      /cards.dart
      /forms.dart
      /theme.dart
```

## The Goal
The goal of this breakdown of code is to help developers quickly find relevant code, make changes
to a small number of nearby files, and to review each others' changes quickly and with confidence.