final class BugseeConfigurationData {
  /// Gets whether the Bugsee SDK is enabled or not. if [Null] it fallbacks to a new installed app so it will be enabled.
  final bool? isBugseeEnabled;

  /// Indicate whether the video capturing feature in Bugsee is enabled or not.
  final bool? isVideoCaptureEnabled;

  /// Indicate whether bugsee obscure application data in videos and images or not.
  final bool? isDataObscrured;

  const BugseeConfigurationData({
    this.isBugseeEnabled,
    this.isVideoCaptureEnabled,
    this.isDataObscrured,
  });
}
