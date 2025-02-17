import 'dart:collection';

import 'package:flutter/foundation.dart';

abstract class ViewModel extends ChangeNotifier {
  final Map<String, dynamic> _properties = {};
  final HashSet<String> _propertiesToNotify = HashSet<String>();

  bool _isRecordingPropertiesToNotify = false;
  
  void startRecordingPropertiesToNotify() {
    _propertiesToNotify.clear();
    _isRecordingPropertiesToNotify = true;
  }
  void stopRecordingPropertiesToNotify() {
    _isRecordingPropertiesToNotify = false;
  }
  void _recordPropertyName(String propertyName){
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
}
