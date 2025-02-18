import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

abstract class ViewModel extends ChangeNotifier {
  final Map<String, dynamic> _properties = {};
  final HashSet<String> _propertiesToNotify = HashSet<String>();
  final Map<String, StreamSubscription> _streamSubscriptions = {};

  bool _isRecordingPropertiesToNotify = false;

  void startRecordingPropertiesToNotify() {
    _propertiesToNotify.clear();
    _isRecordingPropertiesToNotify = true;
  }

  void stopRecordingPropertiesToNotify() {
    _isRecordingPropertiesToNotify = false;
  }

  void _recordPropertyName(String propertyName) {
    if (_isRecordingPropertiesToNotify) {
      _propertiesToNotify.add(propertyName);
    }
  }

  void notifyPropertyChanged(String propertyName) {
    if (_propertiesToNotify.contains(propertyName)) {
      notifyListeners();
    }
  }

  T get<T>(String propertyName, T initialValue) {
    _recordPropertyName(propertyName);
    return _properties.putIfAbsent(propertyName, () => initialValue);
  }

  T getLazy<T>(String propertyName, T Function() initialValueProvider) {
    _recordPropertyName(propertyName);
    return _properties.putIfAbsent(propertyName, initialValueProvider);
  }

  void set<T>(String propertyName, T value) {
    _properties[propertyName] = value;
    notifyPropertyChanged(propertyName);
  }

    T getFromStream<T>(String propertyName, Stream<T> Function() getStream, T initialValue) {
    if (!_streamSubscriptions.containsKey(propertyName)) {
      final subscription = getStream().listen((value) {
        set(propertyName, value);
      });
      _streamSubscriptions[propertyName] = subscription;
    }
    return get(propertyName, initialValue);
  }

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions.values) {
      subscription.cancel();
    }
    _streamSubscriptions.clear();
  }
}
