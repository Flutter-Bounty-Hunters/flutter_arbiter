---
title: Naming Conventions
description: How to name common things in Flutter apps. 
synopsis: Naming is critical for communication, speed, and modeling. This post describes a number of important names to learn and use.
layout: layouts/article.jinja
groupOrder: 1
redirectFrom: operations/naming-conventions
---

Names are what bind us in software development. Whether between the members of a team, employees in 
a company, or colleagues in an industry, names communicate intent, strategy, and relationship to
other things. Consistently applying effective names is critical for development speed and correctness.

The world of Flutter app and package development consist of many repeating requirements. Given the
repetition of these requirements, the solutions and approaches deserve effective, consistent names,
so that Flutter developers can communicate clearly about what they're solving, and how they're
solving it.

This article includes a number of useful names for Flutter development.

## User Journeys
A Flutter app consists of a bundle of features. Most of those features are user journeys - a series
of user interfaces, connected by buttons, which produce some result. For example, sign-in, sign-up,
and checkout are all examples of user journeys that an app might implement.

Within the world of user journey development, there are a few important, repeated concepts.

### Flow
A **Flow** is a composable widget that implements a user journey. Many user journeys include multiple
steps. A Flow is the widget that brings these steps together. 

For example, consider an app that configures a smart thermostat in your home. The thermostat 
configuration journey includes many steps, from showing the user how to physically install the 
thermostat, to connecting to the thermostat, to setting up a schedule for the thermostat. This user 
journey is self-contained, and therefore it can be built within a single widget known as a Flow. 

### Screen
A **Screen** is a widget, as the name suggests, which is responsible for the entire user interface
that appears on the device screen. Importantly, this includes control over the status bar, app bars,
drawers, and any other top-level chrome.

The concept of a **Screen** is important because it says that only a single widget should control
top level chrome. When top-level chrome is controlled by multiple widgets at the same time, it creates
an opportunity for race conditions and other unexpected visual results. This can be solved by making
one widget responsible for all top-level chrome, called a **Screen**.

### Page
A **Page** is a widget that contains a primary piece of content. 

This definition is a bit ambiguous, but taken in coordination with a Screen, the concept of a Page 
is useful.

Often, a **Screen** consists of a few top-level chrome elements, such as an app bar and a drawer,
but the primary content within that Screen changes over time. For example, if a Screen shows a
navigation drawer, then by definition that drawer can change the primary content within the Screen.

A Page can be used to extract the primary content from a Screen, such that the Screen can navigate
between Pages. The Pages can ignore the details of the top-level chrome, and the Screen can ignore
differences between Pages.

But Pages aren't limited to the primary content of a Screen. There are other situations where a
similar relationship is useful. For example, imagine a popup dialog that describes a new feature.
Perhaps that popup dialog wants to show a series of marketing messages that the user can swipe
between. Each of those marketing messages is a Page, and the popup dialog is only responsible for
swiping left/right between the Pages.

Thus, a Page is a widget that contains a primary piece of content, which might appear within a
Screen, bottom sheet, popup dialog, card, or any other container that navigates across multiple
pieces of primary content.

## User Interfaces
App development typically consists primarily of user interface development. Occasionally an app
makes a network call, runs a database query, or checks a device sensor. But all of these behaviors
are in service of the user interface, which connects the human user to the value of the app.

### View Model
A **View Model** is an object that models the information presented by a user interface, as well as
actions that the user interface can take. The purpose of a View Model is to separate rendering
concerns from data access concerns. When a widget is based on a View Model, the widget's visuals
are easily tested and verified for all possible conditions.

## Infrastructure
Infrastructure includes all the tooling that's assembled behind the scenes to make Flutter user
experiences possible.

### Network Client
Nearly every Flutter app makes network calls. A **Network Client** is an object that knows how to 
make every network call for a given server or service.

Typically, all calls to a service share a number of access details. For example, a service likely
uses a single base URL for all calls. The service likely publishes some number of endpoints that
require authorization, and that authorization process is the same for all such endpoints. The
transport format for data sent to the service, as well as the transport format for data received
from the service, is likely the same for all endpoints. The meaning attached to various HTTP status
codes, as well as status codes that are included in service responses, are likely to follow the same
rules for all such endpoints.

Given the many details that are similar or identical among endpoints within a single service, it's
useful to collect all such calls within a single Dart class, whose job is to execute any such
network call. This class is a Network Client.

## Domain Modeling
Domain modeling is the process of defining roles, values, and rules within an app that are related
to business concerns. Domain models do not model user interfaces, nor are they defined by network
payloads. The following concepts are common in domain modeling.

### Repository
A **Repository** is an object that queries and (possibly) saves domain data from/to some kind of 
data source.

A social media app might define a `PostRepository`. A cooking app might define a `RecipeRepository`.
A music app might define a `SongRepository`.

A Repository hides its data source(s) so that the app can query and save domain data without worrying
about networking, files, databases or other infrastructure requirements.

### Service
A **Service** is an object that implements a domain behavior without holding any data of its own.
A Service might query data from Repositories, mutate Aggregates, and create new Value Objects.

A cooking app might define a `NutritionCalculator` Service, which calculates nutrition info for 
recipes. A tax prep app might define a `PersonalTax` Service, which calculates various tax form 
results.
