final class Version implements Comparable<Version> {
  final int major;
  final int minor;
  final int patch;

  /// Optional, depending on your versioning needs.
  final int? build;

  Version(this.major, this.minor, this.patch, [this.build]);

  factory Version.fromString(String versionString) {
    final parts = versionString.split('.');
    final major = int.parse(parts[0]);
    final minor = int.parse(parts[1]);
    final patch = int.parse(parts[2]);
    int? build;

    if (parts.length > 3) {
      build = int.parse(parts[3]);
    }

    return Version(major, minor, patch, build);
  }

  @override
  String toString() {
    if (build != null) {
      return '$major.$minor.$patch.$build';
    }
    return '$major.$minor.$patch';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Version &&
        other.major == major &&
        other.minor == minor &&
        other.patch == patch &&
        other.build == build;
  }

  @override
  int get hashCode => Object.hash(major, minor, patch, build);

  @override
  int compareTo(Version other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    if (patch != other.patch) return patch.compareTo(other.patch);
    if (build != null && other.build != null) {
      return build!.compareTo(other.build!);
    } else if (build == null && other.build == null) {
      return 0;
    } else if (build == null) {
      return -1; // Treat no build as lesser.
    } else {
      return 1; // Treat no build on `other` as lesser.
    }
  }
}
