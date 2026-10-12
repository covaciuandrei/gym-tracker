import 'dart:convert';
import 'dart:io';

import 'package:gym_tracker/data/health_insights/health_snapshot.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

/// Keeps the day's [HealthSnapshot] as one JSON file in the OS cache directory, which iOS
/// never backs up (Apple doesn't allow health data in iCloud) and may purge when space runs low.
@lazySingleton
class HealthCacheStore {
  HealthCacheStore({@ignoreParam Future<Directory> Function()? directory}) : _directory = directory ?? getApplicationCacheDirectory;

  static const _fileName = 'health_insights_cache.json';

  final Future<Directory> Function() _directory;

  Future<HealthSnapshot?> read() async {
    final file = await _file();
    if (!await file.exists()) return null;
    try {
      return HealthSnapshot.fromJson(jsonDecode(await file.readAsString()) as Map<String, Object?>);
    } catch (_) {
      // An unreadable or outdated file is just a cache miss.
      await file.delete();
      return null;
    }
  }

  Future<void> write(HealthSnapshot snapshot) async {
    try {
      final file = await _file();
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(snapshot.toJson()), flush: true);
    } catch (_) {
      // Best effort: if the write fails, the next open reads Apple Health again.
    }
  }

  Future<void> delete() async {
    final file = await _file();
    if (await file.exists()) await file.delete();
  }

  Future<File> _file() async => File('${(await _directory()).path}/$_fileName');
}
