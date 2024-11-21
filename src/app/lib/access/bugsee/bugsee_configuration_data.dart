import 'package:equatable/equatable.dart';

final class BugseeConfigurationData extends Equatable {
  /// Gets whether the Bugsee SDK is enabled or not. if [Null] it fallbacks to a new installed app so it will be enabled.
  final bool? isBugseeEnabled;

  /// Indicate whether the video capturing feature in Bugsee is enabled or not.
  final bool? isVideoCaptureEnabled;

  /// Indicate whether bugsee obscure application data in videos and images or not.
  final bool? isDataObscured;

  /// Indicate whether logs are collected or not.
  final bool? isLogCollectionEnabled;

  /// Indicate whether logs are filtred during reports or not.
  final bool? isLogsFilterEnabled;

  /// Indicate whether attaching file in the Bugsee report is enabled or not
  final bool? attachLogFileEnabled;

  const BugseeConfigurationData({
    this.isBugseeEnabled,
    this.isVideoCaptureEnabled,
    this.isDataObscured,
    this.isLogCollectionEnabled,
    this.isLogsFilterEnabled,
    this.attachLogFileEnabled,
  });

  BugseeConfigurationData copyWith({
    bool? isBugseeEnabled,
    bool? isVideoCaptureEnabled,
    bool? isDataObscured,
    bool? isLogCollectionEnabled,
    bool? isLogsFilterEnabled,
    bool? attachLogFileEnabled,
  }) =>
      BugseeConfigurationData(
        isBugseeEnabled: isBugseeEnabled ?? this.isBugseeEnabled,
        isVideoCaptureEnabled:
            isVideoCaptureEnabled ?? this.isVideoCaptureEnabled,
        isDataObscured: isDataObscured ?? this.isDataObscured,
        isLogCollectionEnabled:
            isLogCollectionEnabled ?? this.isLogCollectionEnabled,
        isLogsFilterEnabled: isLogsFilterEnabled ?? this.isLogsFilterEnabled,
        attachLogFileEnabled: attachLogFileEnabled ?? this.attachLogFileEnabled,
      );

  @override
  List<Object?> get props => [
        isBugseeEnabled,
        isVideoCaptureEnabled,
        isDataObscured,
        isLogCollectionEnabled,
        isLogsFilterEnabled,
        attachLogFileEnabled,
      ];
}
