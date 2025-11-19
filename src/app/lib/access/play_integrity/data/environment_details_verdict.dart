import 'package:equatable/equatable.dart';

/// App access risk labels.
enum AppAccessRiskLabel {
  /// Apps installed by Google Play or preloaded on the device.
  knownInstalled,

  /// Apps installed by Google Play that could capture the screen.
  knownCapturing,

  /// Apps installed by Google Play that could control the device.
  knownControlling,

  /// Apps installed by Google Play that could display overlays.
  knownOverlays,

  /// Other apps are installed (not from Play or preloaded).
  unknownInstalled,

  /// Other apps that could capture the screen.
  unknownCapturing,

  /// Other apps that could control the device.
  unknownControlling,

  /// Other apps that could display overlays.
  unknownOverlays;

  static AppAccessRiskLabel fromString(String value) {
    switch (value) {
      case 'KNOWN_INSTALLED':
        return AppAccessRiskLabel.knownInstalled;
      case 'KNOWN_CAPTURING':
        return AppAccessRiskLabel.knownCapturing;
      case 'KNOWN_CONTROLLING':
        return AppAccessRiskLabel.knownControlling;
      case 'KNOWN_OVERLAYS':
        return AppAccessRiskLabel.knownOverlays;
      case 'UNKNOWN_INSTALLED':
        return AppAccessRiskLabel.unknownInstalled;
      case 'UNKNOWN_CAPTURING':
        return AppAccessRiskLabel.unknownCapturing;
      case 'UNKNOWN_CONTROLLING':
        return AppAccessRiskLabel.unknownControlling;
      case 'UNKNOWN_OVERLAYS':
        return AppAccessRiskLabel.unknownOverlays;
      default:
        throw ArgumentError('Unknown app access risk label: $value');
    }
  }
}

/// Play Protect verdict.
enum PlayProtectVerdict {
  /// Play Protect is on and found no issues.
  noIssues,

  /// Play Protect is on but no scan has been performed yet.
  noData,

  /// Play Protect is turned off.
  possibleRisk,

  /// Play Protect found potentially harmful apps.
  mediumRisk,

  /// Play Protect found dangerous apps.
  highRisk,

  /// Play Protect verdict was not evaluated.
  unevaluated;

  static PlayProtectVerdict fromString(String value) {
    switch (value) {
      case 'NO_ISSUES':
        return PlayProtectVerdict.noIssues;
      case 'NO_DATA':
        return PlayProtectVerdict.noData;
      case 'POSSIBLE_RISK':
        return PlayProtectVerdict.possibleRisk;
      case 'MEDIUM_RISK':
        return PlayProtectVerdict.mediumRisk;
      case 'HIGH_RISK':
        return PlayProtectVerdict.highRisk;
      case 'UNEVALUATED':
        return PlayProtectVerdict.unevaluated;
      default:
        throw ArgumentError('Unknown play protect verdict: $value');
    }
  }

  /// Returns true if there are Play Protect issues.
  bool get hasIssues =>
      this == PlayProtectVerdict.mediumRisk ||
      this == PlayProtectVerdict.highRisk;
}

/// App access risk verdict.
class AppAccessRiskVerdict extends Equatable {
  /// Detected apps that could pose a risk.
  final List<AppAccessRiskLabel> appsDetected;

  const AppAccessRiskVerdict({
    required this.appsDetected,
  });

  factory AppAccessRiskVerdict.fromJson(Map<String, dynamic> json) {
    final appsJson = json['appsDetected'] as List<dynamic>?;
    final apps = appsJson
            ?.map((e) => AppAccessRiskLabel.fromString(e as String))
            .toList() ??
        [];

    return AppAccessRiskVerdict(appsDetected: apps);
  }

  /// Returns true if there are capturing apps detected.
  bool get hasCapturingApps =>
      appsDetected.contains(AppAccessRiskLabel.knownCapturing) ||
      appsDetected.contains(AppAccessRiskLabel.unknownCapturing);

  /// Returns true if there are controlling apps detected.
  bool get hasControllingApps =>
      appsDetected.contains(AppAccessRiskLabel.knownControlling) ||
      appsDetected.contains(AppAccessRiskLabel.unknownControlling);

  /// Returns true if there are overlay apps detected.
  bool get hasOverlayApps =>
      appsDetected.contains(AppAccessRiskLabel.knownOverlays) ||
      appsDetected.contains(AppAccessRiskLabel.unknownOverlays);

  /// Returns true if there are any risky apps detected.
  bool get hasAnyRisk =>
      hasCapturingApps || hasControllingApps || hasOverlayApps;

  @override
  List<Object?> get props => [appsDetected];
}

/// Environment details verdict from Play Integrity API.
///
/// Contains optional information about the app's environment and security.
class EnvironmentDetailsVerdict extends Equatable {
  /// App access risk verdict (optional).
  final AppAccessRiskVerdict? appAccessRiskVerdict;

  /// Play Protect verdict (optional).
  final PlayProtectVerdict? playProtectVerdict;

  const EnvironmentDetailsVerdict({
    this.appAccessRiskVerdict,
    this.playProtectVerdict,
  });

  /// Creates an [EnvironmentDetailsVerdict] from JSON.
  factory EnvironmentDetailsVerdict.fromJson(Map<String, dynamic> json) {
    AppAccessRiskVerdict? appAccessRisk;
    if (json['appAccessRiskVerdict'] != null) {
      appAccessRisk = AppAccessRiskVerdict.fromJson(
          json['appAccessRiskVerdict'] as Map<String, dynamic>);
    }

    PlayProtectVerdict? playProtect;
    if (json['playProtectVerdict'] != null) {
      playProtect =
          PlayProtectVerdict.fromString(json['playProtectVerdict'] as String);
    }

    return EnvironmentDetailsVerdict(
      appAccessRiskVerdict: appAccessRisk,
      playProtectVerdict: playProtect,
    );
  }

  @override
  List<Object?> get props => [appAccessRiskVerdict, playProtectVerdict];
}
