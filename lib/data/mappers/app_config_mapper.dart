import 'package:gym_tracker/data/remote/app_config/app_config_dto.dart';
import 'package:gym_tracker/model/app_config.dart';
import 'package:injectable/injectable.dart';

@injectable
class AppConfigMapper {
  /// Maps an [AppConfigDto] (from Firestore) to a domain [AppConfig].
  AppConfig mapDto(AppConfigDto dto) => AppConfig(
    minRequiredVersion: dto.minRequiredVersion,
    latestVersion: dto.latestVersion,
    maintenanceMode: dto.maintenanceMode,
    maintenanceMessages: Map<String, String>.from(dto.maintenanceMessages),
    androidStoreUrl: dto.androidStoreUrl,
    iosStoreUrl: dto.iosStoreUrl,
  );
}
