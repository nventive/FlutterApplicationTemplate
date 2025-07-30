# GitHub Copilot Instructions for Flutter Application Template

## Project Context

This is a **Flutter/Dart project** that serves as a template for building production-ready mobile applications. The project follows a **Clean Architecture + MVVM pattern** with strict separation of concerns across three main layers.

### Architecture Overview

**Layer Structure:**
- **Access Layer** (`/lib/access/`) - Data sources, repositories, API clients, persistence
- **Business Layer** (`/lib/business/`) - Services, domain models, business logic
- **Presentation Layer** (`/lib/presentation/`) - UI pages, ViewModels, widgets

**Key Technologies:**
- **State Management**: Custom MVVM framework with RxDart streams
- **Dependency Injection**: GetIt service locator
- **HTTP Client**: Dio + Retrofit for API integration
- **Navigation**: GoRouter for declarative routing
- **Localization**: Flutter intl with code generation
- **Testing**: flutter_test, mockito for mocking
- **Logging**: Logger package with custom filters
- **Analytics**: Firebase Analytics and Remote Config

## Code Style Guidelines

### Dart/Flutter Standards
- Follow the [official Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful, descriptive names for variables, functions, and classes
- Prefer composition over inheritance
- Always use `const` constructors where possible
- Implement proper null safety with `?`, `!`, and null-aware operators
- Use `final` for immutable variables and `late` for late initialization

### Project-Specific Conventions
- Use `final class` for implementation classes that shouldn't be extended
- Implement interfaces with `abstract interface class` 
- Prefer factory constructors for service implementations
- Use trailing commas for better git diffs (enforced by linter)
- Always declare return types explicitly
- Use package imports (no relative imports)

### Naming Conventions
```dart
// Classes: PascalCase
class DadJokesService {}
abstract interface class DadJokesRepository {}

// Files: snake_case matching class names
dad_jokes_service.dart
dad_jokes_repository.dart

// Variables and functions: camelCase
final dadJokesService = GetIt.I<DadJokesService>();
Future<void> toggleIsFavorite(DadJoke dadJoke) async {}

// Private members: prefix with underscore
final DadJokesRepository _dadJokesRepository;
```

## MVVM Framework Usage

### ViewModel Implementation
```dart
// Extend from ViewModel base class
class DadJokesPageViewModel extends ViewModel {
  final _service = GetIt.I<DadJokesService>();
  
  // Use getLazy for stream properties
  Stream<List<DadJoke>> get dadJokesStream =>
      getLazy("dadJokesStream", () => _service.dadJokesStream);
  
  // Use get/set for simple properties
  bool get isLoading => get("isLoading", false);
  void _setLoading(bool value) => set("isLoading", value);
}
```

### Widget Implementation  
```dart
// Extend MvvmWidget with ViewModel type
final class DadJokesPage extends MvvmWidget<DadJokesPageViewModel> {
  const DadJokesPage({super.key});

  @override
  DadJokesPageViewModel getViewModel() => DadJokesPageViewModel();

  @override
  Widget build(BuildContext context, DadJokesPageViewModel viewModel) {
    return Scaffold(/* UI implementation */);
  }
}
```

## Repository Pattern Implementation

### Interface Definition
```dart
@RestApi(baseUrl: 'https://api.example.com')
abstract interface class ExampleRepository {
  factory ExampleRepository(Dio dio, {String baseUrl}) = _ExampleRepository;
  
  @GET('/endpoint')
  Future<ResponseData> getData();
}
```

### Service Layer Usage
```dart
abstract interface class ExampleService implements Disposable {
  factory ExampleService(ExampleRepository repository, Logger logger) = _ExampleService;
  
  Stream<List<Model>> get dataStream;
  Future<List<Model>> getData();
}
```

## Flutter-Specific Best Practices

### Widget Lifecycle
- Always use `StatelessWidget` when no local state is needed
- Prefer `const` constructors for better performance
- Use `Key` parameters for widgets that need to maintain state
- Implement proper disposal in ViewModels (streams, subscriptions)

### UI Patterns
```dart
// Use StreamBuilder for reactive UI
StreamBuilder<List<Data>>(
  stream: viewModel.dataStream,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return DataListView(data: snapshot.data!);
    } else if (snapshot.hasError) {
      return ErrorWidget(error: snapshot.error!);
    } else {
      return const CircularProgressIndicator();
    }
  },
)

// Use proper localization
final local = context.local;
Text(local.welcomeMessage)

// Implement responsive design
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return TabletLayout();
    } else {
      return MobileLayout();
    }
  },
)
```

### Async Patterns
```dart
// Always use async/await for better error handling
Future<void> loadData() async {
  try {
    _setLoading(true);
    final data = await _service.getData();
    _updateData(data);
  } catch (error) {
    _logger.e('Failed to load data', error);
    _setError(error.toString());
  } finally {
    _setLoading(false);
  }
}
```

## Testing Guidelines

### Test Structure
```dart
// Unit tests for services
group('DadJokesService', () {
  late DadJokesService service;
  late MockDadJokesRepository mockRepository;

  setUp(() {
    mockRepository = MockDadJokesRepository();
    service = DadJokesService(mockRepository, MockLogger());
  });

  test('should return dad jokes when repository succeeds', () async {
    // Arrange
    when(mockRepository.getDadJokes()).thenAnswer((_) async => mockData);
    
    // Act
    final result = await service.getDadJokes();
    
    // Assert
    expect(result, isA<List<DadJoke>>());
    verify(mockRepository.getDadJokes()).called(1);
  });
});
```

### Widget Testing
```dart
testWidgets('DadJokesPage displays jokes correctly', (tester) async {
  // Arrange
  await tester.pumpWidget(TestApp(child: DadJokesPage()));
  
  // Act
  await tester.pumpAndSettle();
  
  // Assert
  expect(find.byType(ListView), findsOneWidget);
  expect(find.byKey(Key('DadJokesContainer')), findsOneWidget);
});
```

## Dependency Injection Setup

### Service Registration
```dart
// Register services in GetIt
GetIt.I.registerSingleton<DadJokesService>(
  DadJokesService(
    GetIt.I<DadJokesRepository>(),
    GetIt.I<Logger>(),
  ),
);

// Register repositories
GetIt.I.registerSingleton<DadJokesRepository>(
  DadJokesRepository(GetIt.I<Dio>()),
);
```

## Error Handling and Logging

### Logging Patterns
```dart
class ExampleService {
  final Logger _logger;
  
  Future<void> performAction() async {
    _logger.d('Starting action with parameters: $params');
    
    try {
      final result = await _repository.performAction();
      _logger.i('Action completed successfully');
      return result;
    } catch (error, stackTrace) {
      _logger.e('Action failed', error, stackTrace);
      rethrow;
    }
  }
}
```

### Exception Handling
```dart
// Use custom exceptions for business logic
class PersistenceException implements Exception {
  final String message;
  const PersistenceException(this.message);
}

// Handle exceptions in ViewModels
try {
  await _service.performAction();
} on PersistenceException catch (e) {
  _setError('Data persistence failed: ${e.message}');
} catch (e) {
  _setError('An unexpected error occurred');
}
```

## Performance Considerations

- Use `const` constructors wherever possible
- Implement lazy loading for expensive operations
- Dispose of streams and subscriptions properly
- Use `ListView.builder` for large lists
- Cache network responses when appropriate
- Minimize widget rebuilds with proper state management

## Common Gotchas

1. **Stream Subscriptions**: Always dispose of stream subscriptions to prevent memory leaks
2. **GetIt Registration**: Ensure services are registered before use
3. **Null Safety**: Use null-aware operators properly (`?.`, `??`, `!`)
4. **Async Gaps**: Avoid gaps in async operations that could cause race conditions
5. **Widget Keys**: Use keys for widgets that need to maintain state across rebuilds
6. **Context Usage**: Don't use BuildContext across async gaps

## File Organization

```
lib/
├── access/           # Data layer
│   ├── [feature]/    # Feature-specific repositories
│   └── data/         # Data models
├── business/         # Business logic layer  
│   └── [feature]/    # Feature-specific services
├── presentation/     # UI layer
│   ├── [feature]/    # Feature-specific pages/widgets
│   ├── mvvm/         # MVVM framework
│   └── styles/       # Theming and styles
├── l10n/            # Localization
└── main.dart        # App entry point
```

Follow this structure when creating new features or components.