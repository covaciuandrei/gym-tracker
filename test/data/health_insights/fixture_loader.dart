import 'dart:convert';
import 'dart:io';

/// Loads the Health Insights fixture JSON files from `test/fixtures/health_insights/`
/// (anonymized, extracted from a sample Apple Health export by `tools/extract_health_fixtures.mjs`).
class HealthInsightsFixtureLoader {
  static const _basePath = 'test/fixtures/health_insights';

  /// Loads and decodes `<fileName>.json` as a JSON array.
  Future<List<dynamic>> loadList(String fileName) async => jsonDecode(await _read(fileName)) as List<dynamic>;

  /// Loads and decodes `<fileName>.json` as a JSON object.
  Future<Map<String, dynamic>> loadObject(String fileName) async => jsonDecode(await _read(fileName)) as Map<String, dynamic>;

  Future<String> _read(String fileName) => File('$_basePath/$fileName.json').readAsString();
}
