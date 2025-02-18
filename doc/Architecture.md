# Software Architecture

## Context

_[Insert context description here]_

_[Create this diagram from the [architecture file](diagrams/architecture.drawio) (context tab) using [Draw.io](https://www.draw.io/)]_

![Context diagram](diagrams/architecture-context.png)

## Functional Overview

This is a summary of the functionalities available to the user.

_[Insert list of functionalities here]_

## Application Structure

_[Insert structure description here]_

_[Create this diagram from the [architecture file](diagrams/architecture.drawio) (structure tab) using [Draw.io](https://www.draw.io/)]_

![Structure diagram](diagrams/architecture-structure.png)

## Solution Structure

The application solution is divided in 2 main areas.

![Solution diagram](diagrams/solution-structure.png)

- `test` contains the tests.
- `lib` contains the shared code used by the application and the tests.
  - It's divided per application layer.

### Access (DAL)

The _data access layer_ is where you would put external dependencies such as API clients and local storage.
Classes providing data should be suffixed with `Repository`.
This is where you put serializable entities.
The associated folder is named `access` (and not `data_access`) so that it shows as the first element alphabetically.

### Business

The business layer is where you put your business services and entities that manipulate data from the data access layer.
Classes providing business services should be suffixed with `Service`.
Entities from the business layer are usually immutable and they don't need to be serializable.

### Presentation

The presentation layer implements the user experience (UX) and the user interface (UI).
It contains all the widgets and state management classes.

# Technical Overview

## General

Topics that apply to the whole application.

### Dependency Injection

This application is designed to use dependency injection (DI) to manage dependencies between components.

See [DependencyInjection.md](DependencyInjection.md) for more details.

### Diagnostics

This application contains a diagnostic overlay.

See [Diagnostics.md](Diagnostics.md) for more details.

### Logging

This application contains a built-in logging system that can be used to log messages to the debugger's console, to the native consoles, or to a file.

See [Logging.md](Logging.md) for more details.

### Forced Update

This application contains a forced update feature.

See [ForcedUpdate.md](ForcedUpdate.md) for more details.

### Kill Switch

This application contains Kill switch feature.

See [KillSwitch.md](KillSwitch.md) for more details.

## Access (DAL)

Data access services (also referred to as _repositories_) are always declared using an interface and implemented in a separate class. These interfaces are meant to be used from the business layer.

### HTTP Requests

See [HTTP.md](HTTP.md) for more details.

### Local Storage

This applications uses [Shared Preferences](https://pub.dev/packages/shared_preferences) to store data locally.

### JSON Serialization

See [Serialization.md](Serialization.md) for more details.

## Business

Business services are always declared using an interface and implemented in a separate class. These interfaces are meant to be used from the presentation layer and sometimes by other business services.

## Presentation

### Navigation

See [Navigation.md](Navigation.md) for more details.

### State Management

This application uses the MVVM pattern. The `ViewModel` class is used as a base class for all ViewModels.
ViewModels have the concept of _dynamic properties_.
These defined using accessors that call the `get` (or variants such as `getLazy`) and optionally `set` methods to automatically trigger widget rebuilds.

Here is an example of a ViewModel showcasing the usage of dynamic properties.
```dart
class HomePageViewModel extends ViewModel {
  // Regular properties don't trigger rebuild if changed.
  final String title = 'Flutter Demo Home Page';

  // Dynamic properties triggers rebuild if changed.
  int get counter => get('counter', 0);
  set counter(int value) => set('counter', value);

  // Dynamic properties can be made using complex sources, such as streams.
  int get autoCounter => getFromStream('autoCounter',
      () => Stream.periodic(const Duration(seconds: 1), (i) => i), 0);

  List<HomeItemViewModel> get items => getLazy(
      'items',
      () => [
            HomeItemViewModel('1'),
            HomeItemViewModel('2'),
            HomeItemViewModel('3'),
          ]);

  Future<int> get someData => getLazy('someData', _loadSomeData);
  set someData(Future<int> value) => set('someData', value);

  Future<int> _loadSomeData() async {
    await Future.delayed(const Duration(seconds: 2));
    return 42;
  }

  void reloadSomeData() {
    someData = _loadSomeData();
  }
}
```

### UI Framework

This applications uses [Flutter](https://flutter.dev/) as the UI framework.

### Design System

This application uses resources from Material Design.

### Localization

This application uses [flutter_localization](https://pub.dev/packages/flutter_localization) to deal with the localization of strings into multiple languages.

See [Localization.md](Localization.md) for more details.