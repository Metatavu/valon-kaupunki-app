import "dart:io";

/// Reads current version number and build number from pubspec.yaml and bumps them by one.
void main() {
  final pubSpecFile = File("pubspec.yaml");
  final spec = pubSpecFile.readAsStringSync();

  final specWithUpdatedVersion = spec.replaceAllMapped(
    RegExp(r"version: (\d+)\.(\d+)\.(\d+)\+(\d+)"),
    (match) {
      if (match.groupCount != 4) throw Exception("invalid version format");
      final major = int.parse(match[1]!);
      final minor = int.parse(match[2]!);
      final patch = int.parse(match[3]!);
      final buildNumber = int.parse(match[4]!);

      return "version: $major.$minor.${patch + 1}+${buildNumber + 1}";
    },
  );

  pubSpecFile.writeAsStringSync(specWithUpdatedVersion, flush: true);
}
