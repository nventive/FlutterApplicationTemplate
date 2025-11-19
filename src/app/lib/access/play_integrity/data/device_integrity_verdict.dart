import 'package:equatable/equatable.dart';

/// Device integrity labels.
enum DeviceIntegrityLabel {
  /// App is running on a device that passes basic system integrity checks.
  meetsBasicIntegrity,

  /// App is running on a genuine and certified Android device.
  meetsDeviceIntegrity,

  /// App is running on a genuine and certified device with recent security update.
  meetsStrongIntegrity,

  /// App is running on Google Play Games for PC emulator.
  meetsVirtualIntegrity;

  static DeviceIntegrityLabel fromString(String value) {
    switch (value) {
      case 'MEETS_BASIC_INTEGRITY':
        return DeviceIntegrityLabel.meetsBasicIntegrity;
      case 'MEETS_DEVICE_INTEGRITY':
        return DeviceIntegrityLabel.meetsDeviceIntegrity;
      case 'MEETS_STRONG_INTEGRITY':
        return DeviceIntegrityLabel.meetsStrongIntegrity;
      case 'MEETS_VIRTUAL_INTEGRITY':
        return DeviceIntegrityLabel.meetsVirtualIntegrity;
      default:
        throw ArgumentError('Unknown device integrity label: $value');
    }
  }
}

/// Device activity level.
enum DeviceActivityLevel {
  /// Lowest activity level (10 or fewer standard / 5 or fewer classic requests).
  level1,

  /// Low-medium activity (11-25 standard / 6-10 classic requests).
  level2,

  /// Medium-high activity (26-50 standard / 11-15 classic requests).
  level3,

  /// Highest activity level (>50 standard / >15 classic requests).
  level4,

  /// Activity level was not evaluated.
  unevaluated;

  static DeviceActivityLevel fromString(String value) {
    switch (value) {
      case 'LEVEL_1':
        return DeviceActivityLevel.level1;
      case 'LEVEL_2':
        return DeviceActivityLevel.level2;
      case 'LEVEL_3':
        return DeviceActivityLevel.level3;
      case 'LEVEL_4':
        return DeviceActivityLevel.level4;
      case 'UNEVALUATED':
        return DeviceActivityLevel.unevaluated;
      default:
        throw ArgumentError('Unknown device activity level: $value');
    }
  }
}

/// Device attributes.
class DeviceAttributes extends Equatable {
  /// Android SDK version of the device.
  final int? sdkVersion;

  const DeviceAttributes({this.sdkVersion});

  factory DeviceAttributes.fromJson(Map<String, dynamic> json) {
    return DeviceAttributes(
      sdkVersion: json['sdkVersion'] as int?,
    );
  }

  @override
  List<Object?> get props => [sdkVersion];
}

/// Recall bit values.
class RecallBitValues extends Equatable {
  final bool bitFirst;
  final bool bitSecond;
  final bool bitThird;

  const RecallBitValues({
    this.bitFirst = false,
    this.bitSecond = false,
    this.bitThird = false,
  });

  factory RecallBitValues.fromJson(Map<String, dynamic> json) {
    return RecallBitValues(
      bitFirst: json['bitFirst'] as bool? ?? false,
      bitSecond: json['bitSecond'] as bool? ?? false,
      bitThird: json['bitThird'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [bitFirst, bitSecond, bitThird];
}

/// Recall write dates.
class RecallWriteDates extends Equatable {
  final int? yyyymmFirst;
  final int? yyyymmSecond;
  final int? yyyymmThird;

  const RecallWriteDates({
    this.yyyymmFirst,
    this.yyyymmSecond,
    this.yyyymmThird,
  });

  factory RecallWriteDates.fromJson(Map<String, dynamic> json) {
    return RecallWriteDates(
      yyyymmFirst: json['yyyymmFirst'] as int?,
      yyyymmSecond: json['yyyymmSecond'] as int?,
      yyyymmThird: json['yyyymmThird'] as int?,
    );
  }

  @override
  List<Object?> get props => [yyyymmFirst, yyyymmSecond, yyyymmThird];
}

/// Device recall information (beta feature).
class DeviceRecall extends Equatable {
  /// The recall bit values.
  final RecallBitValues values;

  /// The recall bit write dates.
  final RecallWriteDates writeDates;

  const DeviceRecall({
    required this.values,
    required this.writeDates,
  });

  factory DeviceRecall.fromJson(Map<String, dynamic> json) {
    return DeviceRecall(
      values: RecallBitValues.fromJson(
          json['values'] as Map<String, dynamic>? ?? {}),
      writeDates: RecallWriteDates.fromJson(
          json['writeDates'] as Map<String, dynamic>? ?? {}),
    );
  }

  @override
  List<Object?> get props => [values, writeDates];
}

/// Device integrity verdict from Play Integrity API.
///
/// Represents the integrity state of the device where the app is running.
class DeviceIntegrityVerdict extends Equatable {
  /// The device recognition labels.
  final List<DeviceIntegrityLabel> labels;

  /// Device attributes (optional).
  final DeviceAttributes? deviceAttributes;

  /// Recent device activity level (optional).
  final DeviceActivityLevel? recentDeviceActivity;

  /// Device recall information (optional, beta).
  final DeviceRecall? deviceRecall;

  const DeviceIntegrityVerdict({
    required this.labels,
    this.deviceAttributes,
    this.recentDeviceActivity,
    this.deviceRecall,
  });

  /// Creates a [DeviceIntegrityVerdict] from JSON.
  factory DeviceIntegrityVerdict.fromJson(Map<String, dynamic> json) {
    final labelsJson = json['deviceRecognitionVerdict'] as List<dynamic>?;
    final labels = labelsJson
            ?.map((e) => DeviceIntegrityLabel.fromString(e as String))
            .toList() ??
        [];

    DeviceAttributes? deviceAttributes;
    if (json['deviceAttributes'] != null) {
      deviceAttributes = DeviceAttributes.fromJson(
          json['deviceAttributes'] as Map<String, dynamic>);
    }

    DeviceActivityLevel? recentDeviceActivity;
    if (json['recentDeviceActivity'] != null) {
      final activityMap = json['recentDeviceActivity'] as Map<String, dynamic>;
      if (activityMap['deviceActivityLevel'] != null) {
        recentDeviceActivity = DeviceActivityLevel.fromString(
            activityMap['deviceActivityLevel'] as String);
      }
    }

    DeviceRecall? deviceRecall;
    if (json['deviceRecall'] != null) {
      deviceRecall =
          DeviceRecall.fromJson(json['deviceRecall'] as Map<String, dynamic>);
    }

    return DeviceIntegrityVerdict(
      labels: labels,
      deviceAttributes: deviceAttributes,
      recentDeviceActivity: recentDeviceActivity,
      deviceRecall: deviceRecall,
    );
  }

  /// Returns true if device meets basic integrity.
  bool get meetsBasicIntegrity =>
      labels.contains(DeviceIntegrityLabel.meetsBasicIntegrity);

  /// Returns true if device meets device integrity.
  bool get meetsDeviceIntegrity =>
      labels.contains(DeviceIntegrityLabel.meetsDeviceIntegrity);

  /// Returns true if device meets strong integrity.
  bool get meetsStrongIntegrity =>
      labels.contains(DeviceIntegrityLabel.meetsStrongIntegrity);

  /// Returns true if device meets virtual integrity (Google Play Games for PC).
  bool get meetsVirtualIntegrity =>
      labels.contains(DeviceIntegrityLabel.meetsVirtualIntegrity);

  /// Returns true if device is trustworthy (meets at least basic integrity).
  bool get isTrustworthy => labels.isNotEmpty;

  @override
  List<Object?> get props =>
      [labels, deviceAttributes, recentDeviceActivity, deviceRecall];
}
