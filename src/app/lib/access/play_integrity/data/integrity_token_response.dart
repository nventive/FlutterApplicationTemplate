import 'package:app/access/play_integrity/data/account_details_verdict.dart';
import 'package:app/access/play_integrity/data/app_integrity_verdict.dart';
import 'package:app/access/play_integrity/data/device_integrity_verdict.dart';
import 'package:app/access/play_integrity/data/environment_details_verdict.dart';
import 'package:equatable/equatable.dart';

/// Complete integrity token response from Play Integrity API.
///
/// This represents the full verdict payload after decryption and verification.
class IntegrityTokenResponse extends Equatable {
  /// Request details.
  final RequestDetails requestDetails;

  /// Application integrity verdict.
  final AppIntegrityVerdict appIntegrity;

  /// Device integrity verdict.
  final DeviceIntegrityVerdict deviceIntegrity;

  /// Account details verdict.
  final AccountDetailsVerdict accountDetails;

  /// Environment details verdict (optional).
  final EnvironmentDetailsVerdict? environmentDetails;

  const IntegrityTokenResponse({
    required this.requestDetails,
    required this.appIntegrity,
    required this.deviceIntegrity,
    required this.accountDetails,
    this.environmentDetails,
  });

  /// Creates an [IntegrityTokenResponse] from JSON payload.
  factory IntegrityTokenResponse.fromJson(Map<String, dynamic> json) {
    return IntegrityTokenResponse(
      requestDetails: RequestDetails.fromJson(
          json['requestDetails'] as Map<String, dynamic>),
      appIntegrity: AppIntegrityVerdict.fromJson(
          json['appIntegrity'] as Map<String, dynamic>),
      deviceIntegrity: DeviceIntegrityVerdict.fromJson(
          json['deviceIntegrity'] as Map<String, dynamic>),
      accountDetails: AccountDetailsVerdict.fromJson(
          json['accountDetails'] as Map<String, dynamic>),
      environmentDetails: json['environmentDetails'] != null
          ? EnvironmentDetailsVerdict.fromJson(
              json['environmentDetails'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Returns true if the overall integrity check passed.
  ///
  /// This is a convenience method that checks if:
  /// - Device is trustworthy (meets at least basic integrity)
  /// - App is recognized by Google Play
  /// - User has a valid license
  bool get isIntegrityCheckPassed {
    return deviceIntegrity.isTrustworthy &&
        appIntegrity.isPlayRecognized &&
        accountDetails.isLicensed;
  }

  /// Returns true if the device meets strong integrity requirements.
  bool get meetsStrongIntegrity => deviceIntegrity.meetsStrongIntegrity;

  /// Returns true if there are environment security concerns.
  bool get hasEnvironmentConcerns {
    if (environmentDetails == null) return false;

    final hasAppRisk =
        environmentDetails!.appAccessRiskVerdict?.hasAnyRisk ?? false;
    final hasPlayProtectIssues =
        environmentDetails!.playProtectVerdict?.hasIssues ?? false;

    return hasAppRisk || hasPlayProtectIssues;
  }

  @override
  List<Object?> get props => [
        requestDetails,
        appIntegrity,
        deviceIntegrity,
        accountDetails,
        environmentDetails
      ];
}

/// Request details from the integrity token.
class RequestDetails extends Equatable {
  /// Application package name this attestation was requested for.
  final String requestPackageName;

  /// Request hash (for standard requests) or nonce (for classic requests).
  final String? requestHash;
  final String? nonce;

  /// Timestamp in milliseconds when the integrity token was requested.
  final int timestampMillis;

  const RequestDetails({
    required this.requestPackageName,
    this.requestHash,
    this.nonce,
    required this.timestampMillis,
  });

  factory RequestDetails.fromJson(Map<String, dynamic> json) {
    return RequestDetails(
      requestPackageName: json['requestPackageName'] as String,
      requestHash: json['requestHash'] as String?,
      nonce: json['nonce'] as String?,
      timestampMillis: json['timestampMillis'] is int
          ? json['timestampMillis'] as int
          : int.parse(json['timestampMillis'] as String),
    );
  }

  /// Returns the age of the token in milliseconds.
  int getAgeInMillis() {
    return DateTime.now().millisecondsSinceEpoch - timestampMillis;
  }

  /// Returns true if the token is still fresh (within the specified duration).
  bool isFresh(Duration maxAge) {
    return getAgeInMillis() < maxAge.inMilliseconds;
  }

  @override
  List<Object?> get props =>
      [requestPackageName, requestHash, nonce, timestampMillis];
}
