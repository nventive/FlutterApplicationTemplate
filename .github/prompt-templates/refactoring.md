# Refactoring Template

Use this template when refactoring existing code to improve maintainability, performance, or architecture while preserving functionality. This template ensures safe refactoring practices within the MVVM + Clean Architecture pattern.

## Refactoring Context
**Target Code/Component**: [Specify what needs to be refactored]
**Refactoring Goal**: [Improve performance, maintainability, readability, etc.]
**Scope**: [Files, classes, or methods affected]
**Risk Level**: [Low/Medium/High - based on complexity and impact]

## Pre-Refactoring Analysis

### 1. Document Current Behavior
- [ ] **Identify all public interfaces** that must remain unchanged
- [ ] **List current functionality** that must be preserved
- [ ] **Document dependencies** and coupling with other components
- [ ] **Catalog existing tests** that validate current behavior

### 2. Identify Code Smells
Common patterns to look for in this codebase:

#### Architecture Violations
```dart
// Problem: Business logic in ViewModel
class BadViewModel extends ViewModel {
  Future<void> complexBusinessLogic() async {
    // Business logic should be in Service layer
    final data = await repository.getData();
    final processed = data.map((item) => {
      // Complex transformation logic here
    }).toList();
  }
}

// Solution: Move to Service layer
class GoodViewModel extends ViewModel {
  final _service = GetIt.I<DataService>();
  
  Future<void> triggerBusinessLogic() async {
    await _service.processData(); // Delegate to service
  }
}
```

#### Dependency Issues
```dart
// Problem: Direct instantiation instead of DI
class BadService {
  final repository = ConcreteRepository(); // Hard dependency
  
  Future<void> doWork() async {
    final data = await repository.getData();
  }
}

// Solution: Use dependency injection
abstract interface class DataService {
  factory DataService(DataRepository repository, Logger logger) = _DataService;
}

final class _DataService implements DataService {
  final DataRepository _repository;
  final Logger _logger;
  
  _DataService(DataRepository repository, Logger logger)
    : _repository = repository, _logger = logger;
}
```

#### Performance Issues
```dart
// Problem: Inefficient stream usage
class BadViewModel extends ViewModel {
  Stream<List<Item>> get items => Stream.fromFuture(
    repository.getItems(), // New API call on every access
  );
}

// Solution: Cached stream with proper lifecycle
class GoodViewModel extends ViewModel {
  Stream<List<Item>> get items => getFromStream(
    "items",
    () => _service.itemsStream, // Cached stream from service
    <Item>[],
  );
}
```

### 3. Plan the Refactoring Strategy

#### Small Steps Approach
Break down large refactoring into smaller, testable changes:

1. **Extract Method/Class** - Separate concerns into focused units
2. **Move Method** - Relocate methods to appropriate layers
3. **Replace Dependencies** - Introduce interfaces and DI
4. **Optimize Performance** - Improve algorithms and caching
5. **Clean Up** - Remove dead code and improve naming

## Refactoring Patterns by Layer

### Presentation Layer Refactoring

#### ViewModel Simplification
```dart
// Before: Complex ViewModel with mixed concerns
class ComplexViewModel extends ViewModel {
  final _repository = GetIt.I<DataRepository>();
  final _logger = GetIt.I<Logger>();
  
  Future<void> loadAndProcessData() async {
    try {
      set("isLoading", true);
      
      // Problem: Complex business logic in ViewModel
      final rawData = await _repository.getData();
      final processedData = rawData.where((item) => item.isValid)
          .map((item) => TransformedData(
            id: item.id,
            displayName: item.name.toUpperCase(),
            formattedDate: DateFormat('yyyy-MM-dd').format(item.date),
            // More complex transformations...
          ))
          .toList();
      
      set("data", processedData);
      _logger.i("Data loaded and processed: ${processedData.length} items");
      
    } catch (error) {
      _logger.e("Failed to load data", error);
      set("error", error.toString());
    } finally {
      set("isLoading", false);
    }
  }
}

// After: Simplified ViewModel with proper separation
class RefactoredViewModel extends ViewModel {
  final _dataService = GetIt.I<DataService>();
  
  Stream<List<TransformedData>> get dataStream => getFromStream(
    "dataStream",
    () => _dataService.processedDataStream,
    <TransformedData>[],
  );
  
  bool get isLoading => get("isLoading", false);
  String? get error => get("error", null);
  
  Future<void> refreshData() async {
    try {
      set("isLoading", true);
      set("error", null);
      await _dataService.refreshData();
    } catch (error) {
      set("error", error.toString());
    } finally {
      set("isLoading", false);
    }
  }
}
```

#### Widget Decomposition
```dart
// Before: Large, monolithic widget
class LargeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complex Screen'),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          IconButton(icon: Icon(Icons.filter), onPressed: () {}),
          PopupMenuButton(/* complex menu implementation */),
        ],
      ),
      body: Column(
        children: [
          // Complex header section
          Container(/* complex header UI */),
          
          // Complex filter section  
          Row(/* complex filter UI */),
          
          // Complex list section
          Expanded(
            child: ListView.builder(/* complex list implementation */),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(/* implementation */),
    );
  }
}

// After: Decomposed into focused widgets
class RefactoredScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: const Column(
        children: [
          ScreenHeader(),
          FilterSection(), 
          Expanded(child: DataList()),
        ],
      ),
      floatingActionButton: const AddButton(),
    );
  }
  
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Complex Screen'),
      actions: const [
        SearchButton(),
        FilterButton(), 
        OptionsMenu(),
      ],
    );
  }
}

// Extract focused widgets
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key});
  
  @override
  Widget build(BuildContext context) {
    // Focused header implementation
    return Container(/* header UI */);
  }
}
```

### Business Layer Refactoring

#### Service Decomposition
```dart
// Before: God service with multiple responsibilities
class MonolithicService {
  Future<void> manageUserData() async {
    // User authentication
    await authenticate();
    
    // Data fetching
    final userData = await fetchUserData();
    
    // Data processing
    final processedData = processUserData(userData);
    
    // Analytics tracking
    trackUserActivity(processedData);
    
    // Notifications
    sendNotifications(processedData);
  }
}

// After: Decomposed into focused services
abstract interface class AuthenticationService {
  Future<void> authenticate();
  Future<bool> isAuthenticated();
}

abstract interface class UserDataService {
  Future<UserData> fetchUserData();
  Future<UserData> processUserData(RawUserData raw);
  Stream<UserData> get userDataStream;
}

abstract interface class AnalyticsService {
  Future<void> trackUserActivity(UserData data);
}

abstract interface class NotificationService {
  Future<void> sendNotifications(UserData data);
}

// Coordinator service for complex workflows
abstract interface class UserManagementService {
  factory UserManagementService(
    AuthenticationService auth,
    UserDataService userData,
    AnalyticsService analytics,
    NotificationService notifications,
  ) = _UserManagementService;
  
  Future<void> initializeUser();
}
```

#### State Management Optimization
```dart
// Before: Inefficient state management
class InefficientService {
  final BehaviorSubject<List<Item>> _allItems = BehaviorSubject.seeded([]);
  final BehaviorSubject<String> _filter = BehaviorSubject.seeded('');
  
  Stream<List<Item>> get filteredItems => Rx.combineLatest2(
    _allItems.stream,
    _filter.stream,
    (List<Item> items, String filter) {
      // Problem: Filtering happens on every emission
      return items.where((item) => 
        item.name.toLowerCase().contains(filter.toLowerCase())
      ).toList();
    },
  );
}

// After: Optimized with caching and debouncing
class OptimizedService {
  final BehaviorSubject<List<Item>> _allItems = BehaviorSubject.seeded([]);
  final BehaviorSubject<String> _filter = BehaviorSubject.seeded('');
  final BehaviorSubject<List<Item>> _cachedFilteredItems = BehaviorSubject.seeded([]);
  
  late final StreamSubscription _filterSubscription;
  
  OptimizedService() {
    // Debounce filter changes to avoid excessive processing
    _filterSubscription = Rx.combineLatest2(
      _allItems.stream,
      _filter.stream.debounceTime(Duration(milliseconds: 300)),
      _applyFilter,
    ).listen(_cachedFilteredItems.add);
  }
  
  Stream<List<Item>> get filteredItems => _cachedFilteredItems.stream;
  
  List<Item> _applyFilter(List<Item> items, String filter) {
    if (filter.isEmpty) return items;
    
    final lowerFilter = filter.toLowerCase();
    return items.where((item) => 
      item.name.toLowerCase().contains(lowerFilter)
    ).toList();
  }
}
```

### Access Layer Refactoring

#### Repository Pattern Improvements
```dart
// Before: Repository with mixed concerns
class MixedRepository {
  final Dio _dio;
  final SharedPreferences _prefs;
  
  Future<List<Item>> getItems() async {
    // Problem: Caching logic mixed with data fetching
    final cached = _prefs.getString('cached_items');
    if (cached != null) {
      final items = (jsonDecode(cached) as List)
          .map((json) => Item.fromJson(json))
          .toList();
      
      // Problem: Complex cache validation logic
      if (items.isNotEmpty && 
          DateTime.now().difference(items.first.timestamp).inHours < 1) {
        return items;
      }
    }
    
    final response = await _dio.get('/items');
    final items = (response.data as List)
        .map((json) => Item.fromJson(json))
        .toList();
    
    // Problem: Serialization mixed with business logic
    await _prefs.setString('cached_items', jsonEncode(
      items.map((item) => item.toJson()).toList(),
    ));
    
    return items;
  }
}

// After: Separated concerns with cache abstraction
abstract interface class ItemRepository {
  Future<List<Item>> getItems();
  Future<void> refreshItems();
}

abstract interface class CacheManager<T> {
  Future<T?> get(String key);
  Future<void> set(String key, T value, {Duration? ttl});
  Future<bool> isValid(String key);
}

final class _ItemRepository implements ItemRepository {
  final ItemApiClient _apiClient;
  final CacheManager<List<Item>> _cache;
  final Logger _logger;
  
  static const _cacheKey = 'items';
  static const _cacheDuration = Duration(hours: 1);
  
  @override
  Future<List<Item>> getItems() async {
    try {
      // Try cache first
      if (await _cache.isValid(_cacheKey)) {
        final cached = await _cache.get(_cacheKey);
        if (cached != null) {
          _logger.d('Returning cached items: ${cached.length}');
          return cached;
        }
      }
      
      // Fetch from API
      return await refreshItems();
      
    } catch (error) {
      _logger.e('Failed to get items', error);
      rethrow;
    }
  }
  
  @override
  Future<List<Item>> refreshItems() async {
    try {
      final items = await _apiClient.getItems();
      await _cache.set(_cacheKey, items, ttl: _cacheDuration);
      _logger.i('Refreshed items: ${items.length}');
      return items;
    } catch (error) {
      _logger.e('Failed to refresh items', error);
      rethrow;
    }
  }
}
```

## Testing During Refactoring

### Characterization Tests
Create tests that capture current behavior before refactoring:

```dart
// Create comprehensive tests for existing behavior
group('Characterization Tests - Before Refactoring', () {
  late LegacyService service;
  
  setUp(() {
    service = LegacyService();
  });
  
  test('should handle normal data processing', () async {
    // Document exact current behavior
    final input = createTestData();
    final result = await service.processData(input);
    
    expect(result.length, equals(5));
    expect(result.first.status, equals('processed'));
    expect(result.last.timestamp, isNotNull);
  });
  
  test('should handle edge cases', () async {
    // Document edge case behavior
    final emptyResult = await service.processData([]);
    expect(emptyResult, isEmpty);
    
    final nullResult = await service.processData(null);
    expect(nullResult, isNull);
  });
});
```

### Refactoring Tests
Ensure refactored code maintains the same behavior:

```dart
group('Refactored Service Tests', () {
  late RefactoredService service;
  
  setUp(() {
    service = RefactoredService();
  });
  
  test('maintains same data processing behavior', () async {
    // Same test as characterization test
    final input = createTestData();
    final result = await service.processData(input);
    
    expect(result.length, equals(5));
    expect(result.first.status, equals('processed'));
    expect(result.last.timestamp, isNotNull);
  });
  
  test('improves performance while maintaining correctness', () async {
    final stopwatch = Stopwatch()..start();
    
    final result = await service.processLargeDataset(createLargeTestData());
    
    stopwatch.stop();
    
    // Verify functionality is preserved
    expect(result, isNotEmpty);
    
    // Verify performance improvement
    expect(stopwatch.elapsedMilliseconds, lessThan(1000));
  });
});
```

## Performance Optimization Refactoring

### Widget Performance
```dart
// Before: Inefficient widget rebuilds
class InefficientList extends StatelessWidget {
  final List<Item> items;
  
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: items.map((item) => 
        ListTile(
          title: Text(item.name),
          subtitle: Text(DateFormat('yyyy-MM-dd').format(item.date)), // Problem: Formatting on every build
          onTap: () => Navigator.push(/* expensive navigation */),
        )
      ).toList(),
    );
  }
}

// After: Optimized with const widgets and cached formatting
class OptimizedList extends StatelessWidget {
  final List<Item> items;
  
  const OptimizedList({super.key, required this.items});
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder( // Use builder for better performance
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return OptimizedListItem(
          key: ValueKey(item.id), // Proper keys for widget reuse
          item: item,
        );
      },
    );
  }
}

class OptimizedListItem extends StatelessWidget {
  final Item item;
  
  const OptimizedListItem({
    super.key, 
    required this.item,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.name),
      subtitle: Text(item.formattedDate), // Pre-formatted in model
      onTap: () => context.go('/items/${item.id}'), // Use GoRouter
    );
  }
}
```

### Memory Optimization
```dart
// Before: Memory leaks and inefficient caching
class LeakyService {
  final Map<String, StreamSubscription> _subscriptions = {};
  final Map<String, dynamic> _cache = {}; // Grows indefinitely
  
  void subscribeToData(String key) {
    _subscriptions[key] = dataStream.listen((data) {
      _cache[key] = data; // Problem: No size limit or expiration
    });
  }
}

// After: Proper resource management
class OptimizedService implements Disposable {
  final Map<String, StreamSubscription> _subscriptions = {};
  final LRUCache<String, dynamic> _cache = LRUCache(maxSize: 100);
  late final Timer _cleanupTimer;
  
  OptimizedService() {
    // Periodic cleanup
    _cleanupTimer = Timer.periodic(
      Duration(minutes: 5),
      (_) => _performCleanup(),
    );
  }
  
  void subscribeToData(String key) {
    // Cancel existing subscription
    _subscriptions[key]?.cancel();
    
    _subscriptions[key] = dataStream.listen((data) {
      _cache.put(key, data); // LRU cache with size limits
    });
  }
  
  void _performCleanup() {
    // Remove expired cache entries
    _cache.removeExpired();
    
    // Cancel unused subscriptions
    _subscriptions.removeWhere((key, subscription) {
      if (!_isSubscriptionNeeded(key)) {
        subscription.cancel();
        return true;
      }
      return false;
    });
  }
  
  @override
  FutureOr onDispose() async {
    _cleanupTimer.cancel();
    
    for (final subscription in _subscriptions.values) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    _cache.clear();
  }
}
```

## Refactoring Checklist

### Before Starting
- [ ] **Comprehensive test coverage** exists for current functionality
- [ ] **Backup current implementation** (create feature branch)
- [ ] **Document current behavior** and interfaces
- [ ] **Identify breaking changes** and plan migration strategy

### During Refactoring
- [ ] **Make small, incremental changes**
- [ ] **Run tests after each change**
- [ ] **Maintain backward compatibility** where possible
- [ ] **Update documentation** as you go
- [ ] **Use automated refactoring tools** when available

### After Refactoring
- [ ] **All tests pass** (both existing and new)
- [ ] **Performance benchmarks** meet or exceed previous implementation
- [ ] **Code review** by team members
- [ ] **Integration testing** with full application
- [ ] **Update dependent code** if interfaces changed

## Risk Mitigation

### High-Risk Refactoring
For major architectural changes:
- Use **Strangler Fig Pattern** - gradually replace old system
- Implement **Feature Flags** - allow rollback if issues arise
- Create **Adapter Patterns** - ease transition between old and new
- Plan **Gradual Migration** - refactor incrementally over time

### Rollback Strategy
- Keep old implementation available during transition
- Use feature flags to switch between implementations
- Monitor performance and error rates closely
- Have automated rollback triggers for critical issues

## Common Refactoring Anti-Patterns to Avoid

1. **Big Bang Refactoring** - Don't refactor everything at once
2. **Refactoring Without Tests** - Always have comprehensive test coverage first
3. **Changing Behavior** - Refactoring should preserve functionality
4. **Ignoring Performance** - Monitor performance impact during refactoring
5. **Breaking Interfaces** - Maintain backward compatibility when possible

## Documentation Updates

After successful refactoring:
- [ ] Update architecture documentation
- [ ] Revise API documentation
- [ ] Update code comments and inline docs
- [ ] Create migration guides if needed
- [ ] Share refactoring learnings with team