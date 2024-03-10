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

TODO.

## Solution Structure

TODO.

# Technical Overview

## General
Topics that apply to the whole application.

### Startup

TODO.

See [Startup.md](Startup.md) for more details.

### Dependency Injection

This application is designed to use dependency injection (DI) to manage dependencies between components.

See [DependencyInjection.md](DependencyInjection.md) for more details.

### Diagnostics

This application contains several built-in diagnostic tools. Most of them are configurable and can be can be used in release builds, which allows better support for production issues.

See [Diagnostics.md](Diagnostics.md) for more details.

### Logging

This application contains a built-in logging system that can be used to log messages to the debugger's console, to the native consoles, or to a file.

See [Logging.md](Logging.md) for more details.

### Testing

TODO.

See [Testing.md](Testing.md) for more details.

## Access (DAL)

TODO.

### HTTP Requests

See [HTTP.md](HTTP.md) for more details.

### Caching

TODO.

### Local Storage

TODO.

### JSON Serialization

See [Serialization.md](Serialization.md) for more details.

### Authentication

TODO.

## Business

TODO.

## Presentation

TODO.

### Validation

TODO.

See [Validation.md](Validation.md) for more details.

### Analytics

TODO.

See [DefaultAnalytics.md](DefaultAnalytics.md) for more details.

## View

### UI Framework

This applications uses [Flutter](https://flutter.dev/) as the UI framework.

### Platform Specific Code

TODO.

See [PlatformSpecifics.md](PlatformSpecifics.md) for more details.

### Design System

TODO.

### Extended Splash Screen

TODO.

### Reusable UI Components

TODO.
