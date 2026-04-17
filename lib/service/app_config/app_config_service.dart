import 'package:gym_tracker/data/remote/app_config/app_config_source.dart';
import 'package:gym_tracker/model/app_config.dart';
import 'package:injectable/injectable.dart';

part 'app_config_service_exceptions.dart';

@injectable
class AppConfigService {
  const AppConfigService(this._source);

  final AppConfigSource _source;

  /// Returns the current remote [AppConfig].
  /// Throws [AppConfigMissingException] if the document does not exist.
  /// Propagates network / permission errors from the source.
  Future<AppConfig> getAppConfig() async {
    final config = await _source.get();
    if (config == null) throw const AppConfigMissingException();
    return config;
  }
}
