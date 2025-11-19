import 'package:equatable/equatable.dart';

/// App licensing verdict values.
enum AppLicensingVerdict {
  /// The user has an app entitlement (installed/updated from Google Play).
  licensed,

  /// The user doesn't have an app entitlement (sideloaded).
  unlicensed,

  /// Licensing details were not evaluated.
  unevaluated;

  static AppLicensingVerdict fromString(String value) {
    switch (value) {
      case 'LICENSED':
        return AppLicensingVerdict.licensed;
      case 'UNLICENSED':
        return AppLicensingVerdict.unlicensed;
      case 'UNEVALUATED':
        return AppLicensingVerdict.unevaluated;
      default:
        throw ArgumentError('Unknown app licensing verdict: $value');
    }
  }
}

/// Account details verdict from Play Integrity API.
///
/// Contains information about the user's Google Play licensing status.
class AccountDetailsVerdict extends Equatable {
  /// The app licensing verdict.
  final AppLicensingVerdict appLicensingVerdict;

  const AccountDetailsVerdict({
    required this.appLicensingVerdict,
  });

  /// Creates an [AccountDetailsVerdict] from JSON.
  factory AccountDetailsVerdict.fromJson(Map<String, dynamic> json) {
    final verdictString = json['appLicensingVerdict'] as String?;
    final verdict = verdictString != null
        ? AppLicensingVerdict.fromString(verdictString)
        : AppLicensingVerdict.unevaluated;

    return AccountDetailsVerdict(
      appLicensingVerdict: verdict,
    );
  }

  /// Returns true if the user has a valid license.
  bool get isLicensed => appLicensingVerdict == AppLicensingVerdict.licensed;

  @override
  List<Object?> get props => [appLicensingVerdict];
}
