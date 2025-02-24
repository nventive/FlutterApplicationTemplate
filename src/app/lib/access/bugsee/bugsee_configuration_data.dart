final class BugseeConfigurationData {
  /// Gets whether the Bugsee SDK is enabled or not. if [Null] it fallbacks to a new installed app so it will be enabled.
  final bool? isBugseeEnabled;

  /// Indicate whether the video capturing feature in Bugsee is enabled or not.
  final bool? isVideoCaptureEnabled;

  const BugseeConfigurationData({
    required this.isBugseeEnabled,
    required this.isVideoCaptureEnabled,
  });
}
