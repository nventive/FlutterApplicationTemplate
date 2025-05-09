import 'package:equatable/equatable.dart';

enum ConfigErrorEnum {
  invalidReleaseMode(error: 'Bugsee is disabled in debug mode'),
  invalidToken(error: 'Invalid token, cannot start Bugsee reporting'),
  invalidPlatform(error: 'Bugsee cannot be configured on this platform');

  final String error;
  const ConfigErrorEnum({
    required this.error,
  });
}

final class BugseeConfigState extends Equatable {
  /// Indicates if the app requires a restart to reactivate the Bugsee configurations.
  ///
  /// `true` only if `isConfigurationValid == true` and Bugsee is turned on
  final bool isRestartRequired;

  /// Indicates if Bugsee is enabled or not.
  /// by default Bugsee is enabled if `isConfigurationValid == true`.
  final bool isBugseeEnabled;

  /// Indicates whether video capturing is enabled or not.
  /// enabled by default if `isBugseeEnabled == true`.
  ///
  /// Cannot be true if `isBugseeEnabled == false`.
  final bool isVideoCaptureEnabled;

  /// Indicates if Bugsee configuration is valid.
  ///
  /// Configuration is valid if app in release mode and the provided token is valid
  /// following the [bugseeTokenFormat] regex.
  final bool isConfigurationValid;

  /// Indicates whether data is obscured in report videos.
  ///
  /// Cannot be true if `isBugseeEnabled == false`.
  final bool isDataObscured;

  /// Indicates whether log will be collected during Bugsee reporting or not,
  /// by default logs are collected but filterd.
  ///
  /// This value is initialized from [dotenv.env] and shared prefs storage.
  final bool isLogCollectionEnabled;

  /// Indicates whether log will be filterd or not, by default all logs are
  /// filted using [bugseeFilterRegex] defined in [BugseeManager].
  ///
  /// This value is initialized from [dotenv.env] map and shared prefs storage.
  final bool isLogFilterEnabled;

  /// Indicates whether Bugsee will attach the log file when
  /// reporting crashes/exception or not.
  ///
  /// The initial value is taken from [dotenv.env] and shared preferences.
  final bool attachLogFile;

  /// Indicates the configuration error type and message
  /// (debug, invalid token or invalid platform).
  final ConfigErrorEnum? configErrorEnum;

  const BugseeConfigState({
    this.isRestartRequired = false,
    this.isBugseeEnabled = false,
    this.isVideoCaptureEnabled = false,
    this.isConfigurationValid = false,
    this.isDataObscured = false,
    this.isLogCollectionEnabled = false,
    this.isLogFilterEnabled = false,
    this.attachLogFile = false,
    this.configErrorEnum,
  });

  BugseeConfigState copyWith({
    bool? isRestartRequired,
    bool? isBugseeEnabled,
    bool? isVideoCaptureEnabled,
    bool? isConfigurationValid,
    bool? isDataObscured,
    bool? isLogCollectionEnabled,
    bool? isLogFilterEnabled,
    bool? attachLogFile,
    ConfigErrorEnum? configErrorEnum,
  }) =>
      BugseeConfigState(
        isRestartRequired: isRestartRequired ?? this.isRestartRequired,
        isBugseeEnabled: isBugseeEnabled ?? this.isBugseeEnabled,
        isConfigurationValid: isConfigurationValid ?? this.isConfigurationValid,
        isDataObscured: isDataObscured ?? this.isDataObscured,
        isLogFilterEnabled: isLogFilterEnabled ?? this.isLogFilterEnabled,
        attachLogFile: attachLogFile ?? this.attachLogFile,
        isLogCollectionEnabled:
            isLogCollectionEnabled ?? this.isLogCollectionEnabled,
        isVideoCaptureEnabled:
            isVideoCaptureEnabled ?? this.isVideoCaptureEnabled,
        configErrorEnum: configErrorEnum ?? this.configErrorEnum,
      );

  @override
  List<Object?> get props => [
        isRestartRequired,
        isBugseeEnabled,
        isVideoCaptureEnabled,
        isConfigurationValid,
        isDataObscured,
      ];
}
