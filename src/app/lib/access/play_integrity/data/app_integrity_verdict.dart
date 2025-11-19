import 'package:equatable/equatable.dart';

/// App recognition verdict values.
enum AppRecognitionVerdict {
  /// The app and certificate match the versions distributed by Google Play.
  playRecognized,

  /// The certificate or package name does not match Google Play records.
  unrecognizedVersion,

  /// Application integrity was not evaluated.
  unevaluated;

  static AppRecognitionVerdict fromString(String value) {
    switch (value) {
      case 'PLAY_RECOGNIZED':
        return AppRecognitionVerdict.playRecognized;
      case 'UNRECOGNIZED_VERSION':
        return AppRecognitionVerdict.unrecognizedVersion;
      case 'UNEVALUATED':
        return AppRecognitionVerdict.unevaluated;
      default:
        throw ArgumentError('Unknown app recognition verdict: $value');
    }
  }
}

/// Application integrity verdict from Play Integrity API.
///
/// Contains information about the app's integrity and recognition by Google Play.
class AppIntegrityVerdict extends Equatable {
  /// The app recognition verdict.
  final AppRecognitionVerdict appRecognitionVerdict;

  /// The package name of the app.
  final String? packageName;

  /// The SHA-256 digest of app certificates.
  final List<String>? certificateSha256Digest;

  /// The version code of the app.
  final String? versionCode;

  const AppIntegrityVerdict({
    required this.appRecognitionVerdict,
    this.packageName,
    this.certificateSha256Digest,
    this.versionCode,
  });

  /// Creates an [AppIntegrityVerdict] from JSON.
  factory AppIntegrityVerdict.fromJson(Map<String, dynamic> json) {
    final verdictString = json['appRecognitionVerdict'] as String?;
    final verdict = verdictString != null
        ? AppRecognitionVerdict.fromString(verdictString)
        : AppRecognitionVerdict.unevaluated;

    final certificatesJson = json['certificateSha256Digest'] as List<dynamic>?;
    final certificates = certificatesJson?.map((e) => e as String).toList();

    return AppIntegrityVerdict(
      appRecognitionVerdict: verdict,
      packageName: json['packageName'] as String?,
      certificateSha256Digest: certificates,
      versionCode: json['versionCode'] as String?,
    );
  }

  /// Returns true if the app is recognized by Google Play.
  bool get isPlayRecognized =>
      appRecognitionVerdict == AppRecognitionVerdict.playRecognized;

  @override
  List<Object?> get props => [
        appRecognitionVerdict,
        packageName,
        certificateSha256Digest,
        versionCode
      ];
}
