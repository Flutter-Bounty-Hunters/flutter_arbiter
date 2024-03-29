---
title: Flows
description: How to build user journeys.
synopsis: User journeys should be quick to assemble, re-arrange, extend, and compose. Learn how
  to use Flows to accomplish these goals.
layout: layouts/article.jinja
groupOrder: 1
---
## Situation
A user journey that moves through a series of screens or pages.

### Examples
* User sign-up (with multiple steps)
* Configure an IoT device
* Deposit a check
* Book a flight
* Checkout in an online store

## Goals
When implementing a user journey, we'd like to achieve the following.
* It's trivial to add, remove, and re-arrange steps in the user journey.
* It's trivial to define branching behaviors that go to different steps based on user input along the way.
* One user journey can be easily added inside another user journey.
* Screens, pages, and other widgets within a user journey can be re-used in other places without modifying those widgets.
* The user journey can be verified in tests without testing the full app implementation.

## Solution
A Flow is a widget that implements the steps of a user journey.

A Flow is a logical widget, i.e., a non-visual widget. A Flow exists only to codify the set of steps that comprise a given user journey and the order in which they are visited. All visual details within a Flow come from other widgets, which the Flow displays at the desired time.

A Flow is typically comprised either of [Screens]() or [Pages](), though a Flow is permitted to contain any type of visual content.

A Flow is a simple, composable, and low-code solution for implementing a user journey.

## Implementation
The following code illustrates the foundation for a Flow implementation.

```dart
class MyFlow extends StatefulWidget {
  State<MyFlow> createState() => _MyFlowState();
}

class _MyFlowState extends State<MyFlow> {
  _FlowStep _step = _FlowStep.first;

  void _onBackPressedAtStartOfFlow() {
    // Take desired steps when user presses "Back" on
    // the very first screen in the flow. In some user
    // journeys, this situation shouldn't be permitted.
  }

  void _onFlowComplete() {
    // Take desired steps at end of the flow.
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _FlowStep.first:
        return FirstScreen(
          onBack: _onBackPressedAtStartOfFlow(),
          onComplete: () => setState(() {
            _step = _FlowStep.second;
          }),
        );
        
	  case _FlowStep.second:
		return SecondScreen(
		  onBack: () => setState(() {
			_step = _FlowStep.first;
		  }),
		  onComplete: () => setState(() {
			_step = _FlowStep.third;
		  }),
		);
		
	  case _FlowStep.third:
		return ThirdScreen(
		  onBack: () => setState(() {
			_step = _FlowStep.second;
		  }),
		  onComplete: () => setState(() {
			_step = _FlowStep.fourth;
		  }),
		);
		
	  case _FlowStep.fourth:
		return FourthScreen(
		  onBack: () => setState(() {
			_step = _FlowStep.third;
		  }),
		  onComplete: _onFlowComplete,
		);
    }
  }
}

enum _FlowStep {
  first,
  second,
  third,
  fourth;
}
```

The above example omits incoming route parsing, inter-screen transitions, data validation, and error handling. But the example demonstrates the core mechanics of a Flow.

Notice how easy it would be to do any of the following:
* Add a new step anywhere in the existing Flow.
* Switch the second and third steps.
* Make a decision after the second step, which either sends the user to the third step or fourth step based on some condition.
* Display this Flow in the middle of some other Flow.
* Use `FirstScreen` in some other area of the app.
* Test `MyFlow` in isolation, i.e., without including the rest of the app in the test.

The concept of a Flow, and this implementation, accomplishes the stated goals.

### Example: Book a Flight
Booking a flight is an example of a user journey that could be implemented as a Flow.

Let's consider a possible flight booking user journey:
1. Find a flight
2. Pick seats for each departing leg
3. Pick seats for each return leg
4. Car and hotel upsell
5. Payment

Most details of a flight booking implementation depend upon airline industry details and airline system integration. Those details go beyond the scope of this example. The following pseudo-code illustrates what a flight booking Flow might look like.

```dart
class BookFlightFlow extends StatefulWidget {
  State<BookFlightFlow> createState() => _BookFlightFlowState();
}

class _BookFlightFlowState extends State<BookFlightFlow> {
  _FlowStep _step = _FlowStep.findFlight;

  // The flow collects data along the way.
  FlightRoute? _flightRoute;
  SeatSelection? _departingSeats;
  SeatSelection? _returnSeats;
  CarAndHotelSelection? _carAndHotelSelection;

  void _cancelBookingProcess() {
    // Tell the server to cancel the booking, then navigate away.
  }

  void _onFlightBooked() {
    // Navigate away.
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _FlowStep.findFlight:
        return FindFlightScreen(
          // The first time the user gets here, there's no _flightRoute,
          // but if the user returns to this screen, we want to re-populate
          // the previously selected route.
          alreadySelectedRoute: _flightRoute,
          onBack: _cancelBookingProcess,
          onCancel: _cancelBookingProcess,
          // When the user finishes selecting a flight route, that route is
          // reported to the flow, which is then saved and passed to future
          // steps in the flow.
          onFlightSelected: (flightRoute) => setState(() {
            _flightRoute = flightRoute;
            _step = _FlowStep.pickDepartingSeats;
          }),
        );
        
	  case _FlowStep.pickDepartingSeats:
		return PickDepartingSeatsFlow(
		  flightRoute: _flightRoute.departing,
		  alreadySelectedSeats: _departingSeats,
		  onBack: () => setState(() {
			_step = _FlowStep.findFlight;
		  }),
		  onCancel: _cancelBookingProcess,
		  onSeatsSelected: (departingSeats) => setState(() {
		    _departingSeats = departingSeats;
			_step = _FlowStep.pickReturnSeats;
		  }),
		);
		
	  case _FlowStep.pickReturnSeats:
		return PickReturnSeatsFlow(
		  flightRoute: _flightRoute.returning,
		  alreadySelectedSeats: _returnSeats,
		  onBack: () => setState(() {
			_step = _FlowStep.pickDepartingSeats;
		  }),
		  onCancel: _cancelBookingProcess,
		  onSeatsSelected: (returnSeats) => setState(() {
		    _returnSeats = returnSeats;
			_step = _FlowStep.fourth;
		  }),
		);
		
	  case _FlowStep.upsellCarAndHotel:
		return UpsellCarAndHotelFlow(
		  alreadySelectedUpsells: _carAndHotelSelection,
		  onBack: () => setState(() {
			_step = _FlowStep.pickReturnSeats;
		  }),
		  onCancel: _cancelBookingProcess,
		  onUpsellSelected: (upsell) => setState(() {
		    _carAndHotelSelection = upsell;
		    _step = _FlowStep.payment;
		  }),
		  onSkip: () => setState(() {
		    _step = _FlowStep.payment;
		  }),
		);

      case _FlowStep.payment:
		return PaymentScreen(
		  flightRoute: _flightRoute!,
		  departingSeats: _departingSeats!,
		  returnSeats: _returnSeats!,
		  carAndHotelSelection: _carAndHotelSelection!,
		  onBack: () => setState(() {
			_step = _FlowStep.upsellCarAndHotel;
		  });
		  onCancel: _cancelBookingProcess,
		  onComplete: _onFlightBooked,
		);
    }
  }

}

enum _FlowStep {
  findFlight,
  pickDepartingSeats,
  pickReturnSeats,
  upsellCarAndHotel,
  payment;
}
```

Notice that the `BookFlightFlow` internally uses other flows, `PickDepartingSeatsFlow` and `PickReturnSeatsFlow`. This demonstrates the ease of composing multiple Flows together.

Typically, a user provides input during a user journey. That information needs to be saved, and some of it also typically needs to be provided to other steps in the user journey. The flight booking example demonstrates how data can be collected along the way, and provided to various steps as needed. For example, when the user completes the `findFlight` step, the `FindFlightScreen` provides the flight route that the user selected. That route is saved locally in the `State` object. The `_flightRoute.departing` is provided to the `pickDepartingSeats` step, and the `_flightRoute.returning` is provided to the `pickReturnSeats` step.

Retaining user input within a Flow is also important so that when the user presses "back" to return to earlier steps, the user's previous input is restored in those steps.