# Performance Optimization Template

Use this template when analyzing and optimizing performance in the Flutter application. This template covers rendering performance, memory management, network optimization, and overall app responsiveness following the project's architecture patterns.

## Performance Analysis Context
**Performance Issue**: [Describe the specific performance problem]
**Affected Area**: [UI rendering, network, memory, startup time, etc.]
**Impact**: [User experience impact, metrics affected]
**Target Metrics**: [Specific performance goals to achieve]

## Performance Profiling Setup

### Flutter Performance Tools
```dart
// Enable performance overlay in debug mode
class PerformanceDebugApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showPerformanceOverlay: true, // Enable in debug mode only
      checkerboardRasterCacheImages: true, // Highlight cached images
      checkerboardOffscreenLayers: true, // Highlight expensive layers
      home: MyHomePage(),
    );
  }
}

// Custom performance monitoring
class PerformanceMonitor {
  static final Map<String, Stopwatch> _stopwatches = {};
  static final Logger _logger = GetIt.I<Logger>();

  static void startTimer(String operation) {
    _stopwatches[operation] = Stopwatch()..start();
  }

  static void endTimer(String operation) {
    final stopwatch = _stopwatches[operation];
    if (stopwatch != null) {
      stopwatch.stop();
      _logger.d('Performance: $operation took ${stopwatch.elapsedMilliseconds}ms');
      _stopwatches.remove(operation);
    }
  }

  static T measure<T>(String operation, T Function() function) {
    startTimer(operation);
    try {
      return function();
    } finally {
      endTimer(operation);
    }
  }

  static Future<T> measureAsync<T>(String operation, Future<T> Function() function) async {
    startTimer(operation);
    try {
      return await function();
    } finally {
      endTimer(operation);
    }
  }
}
```

### Memory Profiling
```dart
// Memory usage tracking
class MemoryProfiler {
  static void logMemoryUsage(String context) {
    final rss = ProcessInfo.currentRss;
    final maxRss = ProcessInfo.maxRss;
    
    debugPrint('Memory Usage [$context]: Current: ${rss ~/ 1024}KB, Max: ${maxRss ~/ 1024}KB');
  }

  static void trackWidgetMemory(Widget widget) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logMemoryUsage('After ${widget.runtimeType} build');
    });
  }
}
```

## UI Performance Optimization

### Widget Performance

#### Optimized List Rendering
```dart
// Before: Inefficient list with all items in memory
class InefficientList extends StatelessWidget {
  final List<Item> items;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: items.map((item) => 
        ExpensiveListItem(item: item) // All widgets created at once
      ).toList(),
    );
  }
}

// After: Optimized with ListView.builder and const widgets
class OptimizedList extends StatelessWidget {
  final List<Item> items;
  
  const OptimizedList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemExtent: 80.0, // Fixed height for better performance
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
      leading: const Icon(Icons.person), // Const icon
      title: Text(item.name),
      subtitle: Text(item.email),
      trailing: item.isOnline 
        ? const _OnlineIndicator() // Extract to const widget
        : null,
    );
  }
}

class _OnlineIndicator extends StatelessWidget {
  const _OnlineIndicator();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.circle,
      color: Colors.green,
      size: 12,
    );
  }
}
```

#### Efficient Widget Rebuilds
```dart
// Before: Inefficient widget that rebuilds everything
class InefficientWidget extends StatefulWidget {
  @override
  _InefficientWidgetState createState() => _InefficientWidgetState();
}

class _InefficientWidgetState extends State<InefficientWidget> {
  int counter = 0;
  List<String> expensiveData = [];

  @override
  Widget build(BuildContext context) {
    // Problem: Expensive computation on every build
    final processedData = _processExpensiveData(expensiveData);
    
    return Column(
      children: [
        Text('Counter: $counter'),
        Text('Data: ${processedData.length}'),
        ElevatedButton(
          onPressed: () => setState(() => counter++),
          child: Text('Increment'),
        ),
        ExpensiveWidget(data: processedData), // Rebuilds unnecessarily
      ],
    );
  }

  List<String> _processExpensiveData(List<String> data) {
    // Expensive computation
    return data.map((item) => item.toUpperCase()).toList();
  }
}

// After: Optimized with memoization and selective rebuilds
class OptimizedWidget extends StatefulWidget {
  @override
  _OptimizedWidgetState createState() => _OptimizedWidgetState();
}

class _OptimizedWidgetState extends State<OptimizedWidget> {
  int counter = 0;
  List<String> expensiveData = [];
  late List<String> _cachedProcessedData;
  List<String>? _lastExpensiveData;

  @override
  void initState() {
    super.initState();
    _updateProcessedData();
  }

  void _updateProcessedData() {
    if (_lastExpensiveData != expensiveData) {
      _cachedProcessedData = _processExpensiveData(expensiveData);
      _lastExpensiveData = List.from(expensiveData);
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateProcessedData();
    
    return Column(
      children: [
        // Counter section that rebuilds independently
        _CounterSection(
          counter: counter,
          onIncrement: () => setState(() => counter++),
        ),
        
        // Data section with cached processing
        _DataSection(processedData: _cachedProcessedData),
        
        // Expensive widget with const constructor and memo
        ExpensiveWidgetMemo(data: _cachedProcessedData),
      ],
    );
  }

  List<String> _processExpensiveData(List<String> data) {
    return data.map((item) => item.toUpperCase()).toList();
  }
}

class _CounterSection extends StatelessWidget {
  final int counter;
  final VoidCallback onIncrement;

  const _CounterSection({
    required this.counter,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Counter: $counter'),
        ElevatedButton(
          onPressed: onIncrement,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}

// Memoized expensive widget
class ExpensiveWidgetMemo extends StatefulWidget {
  final List<String> data;

  const ExpensiveWidgetMemo({super.key, required this.data});

  @override
  State<ExpensiveWidgetMemo> createState() => _ExpensiveWidgetMemoState();
}

class _ExpensiveWidgetMemoState extends State<ExpensiveWidgetMemo> {
  Widget? _cachedWidget;
  List<String>? _lastData;

  @override
  Widget build(BuildContext context) {
    // Only rebuild if data actually changed
    if (_lastData != widget.data) {
      _cachedWidget = _buildExpensiveContent();
      _lastData = List.from(widget.data);
    }
    
    return _cachedWidget!;
  }

  Widget _buildExpensiveContent() {
    // Expensive widget building logic
    return Container(
      child: Column(
        children: widget.data.map((item) => Text(item)).toList(),
      ),
    );
  }
}
```

### Image Performance

#### Optimized Image Loading
```dart
class OptimizedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const OptimizedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      // Performance optimizations
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
      filterQuality: FilterQuality.medium, // Balance quality vs performance
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        return SizedBox(
          width: width,
          height: height,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        );
      },
    );
  }
}

// Image caching service
class ImageCacheManager {
  static final ImageCache _cache = PaintingBinding.instance.imageCache;
  
  static void optimizeCacheSize() {
    // Optimize cache size based on available memory
    _cache.maximumSize = 100; // Limit number of cached images
    _cache.maximumSizeBytes = 50 * 1024 * 1024; // 50MB cache limit
  }
  
  static void preloadImages(List<String> imageUrls) {
    for (final url in imageUrls) {
      final image = NetworkImage(url);
      precacheImage(image, navigatorKey.currentContext!);
    }
  }
  
  static void clearCache() {
    _cache.clear();
    _cache.clearLiveImages();
  }
}
```

### Animation Performance

#### Optimized Animations
```dart
// Efficient animation controller management
class OptimizedAnimationWidget extends StatefulWidget {
  @override
  _OptimizedAnimationWidgetState createState() => _OptimizedAnimationWidgetState();
}

class _OptimizedAnimationWidgetState extends State<OptimizedAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Use Tween.animate() for better performance
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose(); // Always dispose animation controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: child,
          ),
        );
      },
      child: const _StaticContent(), // Child doesn't rebuild
    );
  }
}

class _StaticContent extends StatelessWidget {
  const _StaticContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text('Animated content'),
    );
  }
}

// Reusable animation mixin
mixin AnimationMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin {
  late AnimationController animationController;
  
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
  
  Animation<T> createTweenAnimation<T>(
    T begin,
    T end, {
    Curve curve = Curves.easeInOut,
  }) {
    return Tween<T>(begin: begin, end: end).animate(
      CurvedAnimation(parent: animationController, curve: curve),
    );
  }
}
```

## Memory Management

### Stream and Subscription Management
```dart
// Proper stream disposal in ViewModels
class OptimizedViewModel extends ViewModel {
  final List<StreamSubscription> _subscriptions = [];
  final CompositeSubscription _compositeSubscription = CompositeSubscription();
  
  @override
  void dispose() {
    // Cancel all subscriptions
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    
    // Cancel composite subscription
    _compositeSubscription.cancel();
    
    super.dispose();
  }
  
  void listenToStream<T>(Stream<T> stream, void Function(T) onData) {
    final subscription = stream.listen(onData);
    _subscriptions.add(subscription);
    
    // Alternative: Use composite subscription
    _compositeSubscription.add(subscription);
  }
  
  // Use getFromStream with proper cleanup
  Stream<List<Item>> get itemsStream => getFromStream(
    "itemsStream",
    () => _service.itemsStream,
    <Item>[],
  );
}

// Composite subscription utility
class CompositeSubscription {
  final List<StreamSubscription> _subscriptions = [];
  
  void add(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }
  
  void cancel() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}
```

### Efficient Data Structures
```dart
// Use appropriate data structures for performance
class OptimizedDataManager {
  // Use Set for O(1) lookups
  final Set<String> _favoriteIds = {};
  
  // Use Map for O(1) key-based access
  final Map<String, Item> _itemsById = {};
  
  // Use LinkedHashMap to maintain insertion order
  final LinkedHashMap<String, Item> _recentItems = LinkedHashMap();
  
  // Use Queue for FIFO operations
  final Queue<String> _searchHistory = Queue();
  
  // Efficient favorite checking
  bool isFavorite(String itemId) {
    return _favoriteIds.contains(itemId); // O(1) operation
  }
  
  // Efficient item lookup
  Item? getItem(String id) {
    return _itemsById[id]; // O(1) operation
  }
  
  // Maintain bounded collections
  void addToSearchHistory(String query) {
    _searchHistory.addFirst(query);
    
    // Keep only last 10 searches
    while (_searchHistory.length > 10) {
      _searchHistory.removeLast();
    }
  }
  
  // Efficient bulk updates
  void updateItems(List<Item> items) {
    // Clear and rebuild in batch for better performance
    _itemsById.clear();
    
    for (final item in items) {
      _itemsById[item.id] = item;
    }
  }
}
```

### Object Pooling
```dart
// Object pool for expensive objects
class ObjectPool<T> {
  final List<T> _pool = [];
  final T Function() _factory;
  final void Function(T)? _reset;
  
  ObjectPool(this._factory, {this.reset});
  
  T acquire() {
    if (_pool.isNotEmpty) {
      final obj = _pool.removeLast();
      _reset?.call(obj);
      return obj;
    }
    return _factory();
  }
  
  void release(T obj) {
    if (_pool.length < 10) { // Limit pool size
      _pool.add(obj);
    }
  }
}

// Example usage for expensive widgets
class ExpensiveWidgetPool {
  static final ObjectPool<ExpensiveWidget> _pool = ObjectPool(
    () => ExpensiveWidget(),
    reset: (widget) => widget.reset(),
  );
  
  static ExpensiveWidget acquire() => _pool.acquire();
  static void release(ExpensiveWidget widget) => _pool.release(widget);
}
```

## Network Performance

### Request Optimization
```dart
// Batch multiple API requests
class BatchApiService {
  final Dio _dio;
  final Duration _batchDelay = Duration(milliseconds: 100);
  final Map<String, List<Completer<dynamic>>> _pendingRequests = {};
  
  BatchApiService(this._dio);

  Future<T> batchRequest<T>(
    String endpoint,
    T Function(dynamic) parser,
  ) async {
    final completer = Completer<T>();
    
    _pendingRequests.putIfAbsent(endpoint, () => []).add(completer);
    
    // Process batch after delay
    Timer(_batchDelay, () => _processBatch(endpoint, parser));
    
    return completer.future;
  }
  
  void _processBatch<T>(String endpoint, T Function(dynamic) parser) async {
    final completers = _pendingRequests.remove(endpoint);
    if (completers == null || completers.isEmpty) return;
    
    try {
      final response = await _dio.get(endpoint);
      final result = parser(response.data);
      
      for (final completer in completers) {
        completer.complete(result);
      }
    } catch (error) {
      for (final completer in completers) {
        completer.completeError(error);
      }
    }
  }
}

// Request deduplication
class RequestDeduplicator {
  final Map<String, Future<dynamic>> _activeRequests = {};
  
  Future<T> deduplicate<T>(
    String key,
    Future<T> Function() requestFactory,
  ) {
    if (_activeRequests.containsKey(key)) {
      return _activeRequests[key]! as Future<T>;
    }
    
    final future = requestFactory();
    _activeRequests[key] = future;
    
    // Clean up after completion
    future.whenComplete(() => _activeRequests.remove(key));
    
    return future;
  }
}
```

### Caching Optimization
```dart
// Intelligent cache management
class IntelligentCacheManager {
  final SharedPreferences _prefs;
  final Logger _logger;
  final Map<String, DateTime> _cacheTimestamps = {};
  
  IntelligentCacheManager(this._prefs, this._logger);
  
  Future<T?> get<T>(
    String key,
    T Function(String) deserializer, {
    Duration? maxAge,
  }) async {
    final cacheKey = 'cache_$key';
    final timestampKey = 'timestamp_$key';
    
    final cachedData = _prefs.getString(cacheKey);
    final timestampString = _prefs.getString(timestampKey);
    
    if (cachedData == null || timestampString == null) {
      return null;
    }
    
    final timestamp = DateTime.tryParse(timestampString);
    if (timestamp == null) {
      await _invalidateCache(key);
      return null;
    }
    
    final age = DateTime.now().difference(timestamp);
    if (maxAge != null && age > maxAge) {
      await _invalidateCache(key);
      return null;
    }
    
    try {
      return deserializer(cachedData);
    } catch (e) {
      _logger.w('Failed to deserialize cached data for key: $key', e);
      await _invalidateCache(key);
      return null;
    }
  }
  
  Future<void> set<T>(
    String key,
    T data,
    String Function(T) serializer,
  ) async {
    final cacheKey = 'cache_$key';
    final timestampKey = 'timestamp_$key';
    
    try {
      final serializedData = serializer(data);
      await _prefs.setString(cacheKey, serializedData);
      await _prefs.setString(timestampKey, DateTime.now().toIso8601String());
      _cacheTimestamps[key] = DateTime.now();
    } catch (e) {
      _logger.e('Failed to cache data for key: $key', e);
    }
  }
  
  Future<void> _invalidateCache(String key) async {
    final cacheKey = 'cache_$key';
    final timestampKey = 'timestamp_$key';
    
    await _prefs.remove(cacheKey);
    await _prefs.remove(timestampKey);
    _cacheTimestamps.remove(key);
  }
  
  // Preemptive cache warming
  Future<void> warmCache(List<String> keys) async {
    for (final key in keys) {
      // Trigger cache population in background
      _warmCacheForKey(key);
    }
  }
  
  void _warmCacheForKey(String key) {
    // Implementation depends on your data source
  }
}
```

## Database Performance

### Efficient Data Queries
```dart
// Optimized database operations
class OptimizedDatabaseService {
  final Database _database;
  
  OptimizedDatabaseService(this._database);
  
  // Use prepared statements for repeated queries
  Future<List<Map<String, dynamic>>> getUsersByStatus(String status) async {
    return await _database.rawQuery(
      'SELECT * FROM users WHERE status = ? ORDER BY created_at DESC LIMIT 50',
      [status],
    );
  }
  
  // Batch operations for better performance
  Future<void> batchInsertUsers(List<User> users) async {
    final batch = _database.batch();
    
    for (final user in users) {
      batch.insert('users', user.toMap());
    }
    
    await batch.commit(noResult: true);
  }
  
  // Use indexes for frequently queried columns
  Future<void> createIndexes() async {
    await _database.execute('CREATE INDEX IF NOT EXISTS idx_users_status ON users(status)');
    await _database.execute('CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at)');
    await _database.execute('CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)');
  }
  
  // Pagination for large datasets
  Future<List<User>> getUsersPaginated({
    required int page,
    required int pageSize,
    String? searchTerm,
  }) async {
    final offset = (page - 1) * pageSize;
    
    String query = 'SELECT * FROM users';
    List<dynamic> arguments = [];
    
    if (searchTerm != null && searchTerm.isNotEmpty) {
      query += ' WHERE name LIKE ? OR email LIKE ?';
      arguments.addAll(['%$searchTerm%', '%$searchTerm%']);
    }
    
    query += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    arguments.addAll([pageSize, offset]);
    
    final results = await _database.rawQuery(query, arguments);
    return results.map((row) => User.fromMap(row)).toList();
  }
}
```

## App Startup Performance

### Optimized App Initialization
```dart
// Lazy initialization of services
class LazyServiceInitializer {
  static final Map<Type, dynamic> _services = {};
  static final Map<Type, Future<dynamic>> _initializing = {};
  
  static T getService<T>() {
    if (_services.containsKey(T)) {
      return _services[T] as T;
    }
    
    throw StateError('Service $T not initialized. Call initializeService<$T>() first.');
  }
  
  static Future<T> initializeService<T>(Future<T> Function() factory) async {
    if (_services.containsKey(T)) {
      return _services[T] as T;
    }
    
    if (_initializing.containsKey(T)) {
      return await _initializing[T]! as T;
    }
    
    final future = factory();
    _initializing[T] = future;
    
    try {
      final service = await future;
      _services[T] = service;
      return service;
    } finally {
      _initializing.remove(T);
    }
  }
}

// Parallel service initialization
class ParallelInitializer {
  static Future<void> initializeApp() async {
    final stopwatch = Stopwatch()..start();
    
    // Initialize critical services first
    await _initializeCriticalServices();
    
    // Initialize non-critical services in parallel
    await _initializeNonCriticalServices();
    
    stopwatch.stop();
    debugPrint('App initialization took: ${stopwatch.elapsedMilliseconds}ms');
  }
  
  static Future<void> _initializeCriticalServices() async {
    // These must be initialized before the app can start
    await Future.wait([
      LazyServiceInitializer.initializeService<SharedPreferences>(
        () async => await SharedPreferences.getInstance(),
      ),
      LazyServiceInitializer.initializeService<Logger>(
        () async => Logger(),
      ),
    ]);
  }
  
  static Future<void> _initializeNonCriticalServices() async {
    // These can be initialized in background
    unawaited(Future.wait([
      LazyServiceInitializer.initializeService<FirebaseApp>(
        () async => await Firebase.initializeApp(),
      ),
      LazyServiceInitializer.initializeService<PackageInfo>(
        () async => await PackageInfo.fromPlatform(),
      ),
      _preloadCriticalAssets(),
    ]));
  }
  
  static Future<void> _preloadCriticalAssets() async {
    // Preload images and other assets
    final context = navigatorKey.currentContext!;
    await Future.wait([
      precacheImage(AssetImage('assets/images/logo.png'), context),
      precacheImage(AssetImage('assets/images/placeholder.png'), context),
    ]);
  }
}
```

## Performance Testing and Monitoring

### Performance Benchmarking
```dart
// Performance benchmark suite
class PerformanceBenchmark {
  static final Logger _logger = GetIt.I<Logger>();
  
  static Future<void> runBenchmarks() async {
    await _benchmarkListScrolling();
    await _benchmarkDataProcessing();
    await _benchmarkNetworkRequests();
    await _benchmarkMemoryUsage();
  }
  
  static Future<void> _benchmarkListScrolling() async {
    final stopwatch = Stopwatch()..start();
    
    // Simulate list with 1000 items
    final items = List.generate(1000, (index) => Item(id: '$index', name: 'Item $index'));
    
    // Measure rendering time
    // This would need to be integrated with widget testing
    
    stopwatch.stop();
    _logger.i('List scrolling benchmark: ${stopwatch.elapsedMilliseconds}ms');
  }
  
  static Future<void> _benchmarkDataProcessing() async {
    final stopwatch = Stopwatch()..start();
    
    // Simulate data processing
    final data = List.generate(10000, (index) => 'Item $index');
    final processed = data.map((item) => item.toUpperCase()).toList();
    
    stopwatch.stop();
    _logger.i('Data processing benchmark: ${stopwatch.elapsedMilliseconds}ms');
    
    assert(stopwatch.elapsedMilliseconds < 100, 'Data processing too slow');
  }
  
  static Future<void> _benchmarkNetworkRequests() async {
    final dio = GetIt.I<Dio>();
    final stopwatch = Stopwatch()..start();
    
    try {
      await dio.get('/api/health');
      stopwatch.stop();
      _logger.i('Network request benchmark: ${stopwatch.elapsedMilliseconds}ms');
      
      assert(stopwatch.elapsedMilliseconds < 2000, 'Network request too slow');
    } catch (e) {
      _logger.w('Benchmark network request failed', e);
    }
  }
  
  static Future<void> _benchmarkMemoryUsage() async {
    final beforeMemory = ProcessInfo.currentRss;
    
    // Create temporary objects
    final largeList = List.generate(100000, (index) => 'Data $index');
    
    final afterMemory = ProcessInfo.currentRss;
    final memoryIncrease = afterMemory - beforeMemory;
    
    _logger.i('Memory usage increase: ${memoryIncrease ~/ 1024}KB');
    
    // Clean up
    largeList.clear();
    
    assert(memoryIncrease < 50 * 1024 * 1024, 'Memory usage too high'); // 50MB limit
  }
}
```

### Real-time Performance Monitoring
```dart
// Performance metrics collector
class PerformanceMetrics {
  static final Map<String, List<int>> _metrics = {};
  static Timer? _reportingTimer;
  
  static void initialize() {
    _reportingTimer = Timer.periodic(
      Duration(minutes: 5),
      (_) => _reportMetrics(),
    );
  }
  
  static void recordMetric(String name, int value) {
    _metrics.putIfAbsent(name, () => []).add(value);
    
    // Keep only last 100 measurements
    final values = _metrics[name]!;
    if (values.length > 100) {
      values.removeAt(0);
    }
  }
  
  static void _reportMetrics() {
    final report = <String, dynamic>{};
    
    for (final entry in _metrics.entries) {
      final values = entry.value;
      if (values.isNotEmpty) {
        final average = values.reduce((a, b) => a + b) / values.length;
        final max = values.reduce((a, b) => a > b ? a : b);
        final min = values.reduce((a, b) => a < b ? a : b);
        
        report[entry.key] = {
          'average': average.round(),
          'max': max,
          'min': min,
          'count': values.length,
        };
      }
    }
    
    // Send metrics to analytics service
    GetIt.I<Logger>().i('Performance metrics: $report');
    
    // Optional: Send to remote analytics
    // FirebaseAnalytics.instance.logEvent(
    //   name: 'performance_metrics',
    //   parameters: report,
    // );
  }
  
  static void dispose() {
    _reportingTimer?.cancel();
    _metrics.clear();
  }
}

// Frame rate monitoring
class FrameRateMonitor {
  static int _frameCount = 0;
  static DateTime _lastTime = DateTime.now();
  static final ValueNotifier<double> _fpsNotifier = ValueNotifier(0.0);
  
  static ValueNotifier<double> get fpsNotifier => _fpsNotifier;
  
  static void initialize() {
    WidgetsBinding.instance.addPostFrameCallback(_onFrame);
  }
  
  static void _onFrame(Duration timestamp) {
    _frameCount++;
    final now = DateTime.now();
    final elapsed = now.difference(_lastTime);
    
    if (elapsed.inSeconds >= 1) {
      final fps = _frameCount / elapsed.inSeconds;
      _fpsNotifier.value = fps;
      
      PerformanceMetrics.recordMetric('fps', fps.round());
      
      _frameCount = 0;
      _lastTime = now;
    }
    
    WidgetsBinding.instance.addPostFrameCallback(_onFrame);
  }
}
```

## Performance Optimization Checklist

### UI Performance
- [ ] **ListView.builder** used for large lists instead of ListView
- [ ] **const constructors** used wherever possible
- [ ] **Widget keys** properly implemented for list items
- [ ] **RepaintBoundary** used to isolate expensive widgets
- [ ] **Image caching** optimized with appropriate cache sizes
- [ ] **Animation controllers** properly disposed
- [ ] **Expensive computations** moved off the main thread

### Memory Management
- [ ] **Stream subscriptions** properly cancelled in dispose()
- [ ] **Large objects** released when no longer needed
- [ ] **Image cache** size limited appropriately
- [ ] **Object pools** used for frequently created/destroyed objects
- [ ] **Memory leaks** identified and fixed
- [ ] **Efficient data structures** chosen for use cases

### Network Performance
- [ ] **Request batching** implemented where appropriate
- [ ] **Response caching** configured correctly
- [ ] **Request deduplication** prevents redundant calls
- [ ] **Connection pooling** optimized
- [ ] **Timeout values** set appropriately
- [ ] **Retry logic** implemented for transient failures

### App Startup
- [ ] **Critical services** initialized first
- [ ] **Non-critical services** initialized in background
- [ ] **Asset preloading** optimized
- [ ] **Splash screen** covers initialization time
- [ ] **Deep links** handled efficiently

### Database Performance
- [ ] **Database indexes** created for frequently queried columns
- [ ] **Batch operations** used for bulk data changes
- [ ] **Query optimization** applied to slow queries
- [ ] **Pagination** implemented for large result sets
- [ ] **Connection management** optimized

## Common Performance Anti-Patterns

1. **Building expensive widgets on every frame**
2. **Not disposing of controllers and subscriptions**
3. **Using ListView instead of ListView.builder for large lists**
4. **Missing const constructors**
5. **Performing synchronous operations on the main thread**
6. **Not optimizing image loading and caching**
7. **Creating new objects unnecessarily in build methods**
8. **Poor state management causing excessive rebuilds**
9. **Not using appropriate data structures**
10. **Ignoring memory leaks and unbounded growth**

## Performance Monitoring in Production

### Setup Performance Tracking
```dart
// Firebase Performance Monitoring integration
class PerformanceTracker {
  static HttpMetric? _currentHttpMetric;
  
  static void startTrace(String traceName) {
    FirebasePerformance.instance.newTrace(traceName).start();
  }
  
  static void stopTrace(String traceName) {
    // Implementation depends on how you store trace references
  }
  
  static void trackHttpRequest(String url, String method) {
    _currentHttpMetric = FirebasePerformance.instance.newHttpMetric(url, method);
    _currentHttpMetric?.start();
  }
  
  static void finishHttpRequest(int responseCode, int responseSize) {
    _currentHttpMetric?.responseCode = responseCode;
    _currentHttpMetric?.responsePayloadSize = responseSize;
    _currentHttpMetric?.stop();
    _currentHttpMetric = null;
  }
}
```

This comprehensive performance optimization template provides actionable strategies for improving Flutter app performance across all areas while following the project's established architecture patterns.