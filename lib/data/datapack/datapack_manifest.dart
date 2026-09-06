/// 06_BACKEND.md §5: CI가 sha256을 계산해 만드는 `manifest.json`.
/// `files`는 상대 경로 -> sha256 hex.
class DatapackManifest {
  const DatapackManifest({required this.dataVersion, required this.files});

  final String dataVersion;
  final Map<String, String> files;

  factory DatapackManifest.fromJson(Map<String, Object?> json) => DatapackManifest(
    dataVersion: json['dataVersion'] as String,
    files: (json['files'] as Map<String, Object?>).map((k, v) => MapEntry(k, v as String)),
  );
}
