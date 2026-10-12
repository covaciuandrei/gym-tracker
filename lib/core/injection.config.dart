// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../cubit/app_version/app_version_cubit.dart' as _i176;
import '../cubit/auth/auth_cubit.dart' as _i548;
import '../cubit/calendar/calendar_cubit.dart' as _i1060;
import '../cubit/checking_update/checking_update_cubit.dart' as _i772;
import '../cubit/health/health_cubit.dart' as _i829;
import '../cubit/health_insights/health_insights_cubit.dart' as _i487;
import '../cubit/health_insights/metric_timeline_cubit.dart' as _i384;
import '../cubit/health_insights/physical_overview_detail_cubit.dart' as _i636;
import '../cubit/membership/membership_cubit.dart' as _i231;
import '../cubit/settings/settings_cubit.dart' as _i411;
import '../cubit/splash/splash_cubit.dart' as _i963;
import '../cubit/stats/stats_cubit.dart' as _i730;
import '../cubit/workout/workout_cubit.dart' as _i800;
import '../data/health_insights/apple_health_repository.dart' as _i315;
import '../data/health_insights/health_cache_store.dart' as _i66;
import '../data/health_insights/health_repository.dart' as _i58;
import '../data/health_insights/healthkit_source.dart' as _i525;
import '../data/mappers/app_config_mapper.dart' as _i710;
import '../data/mappers/attendance_day_mapper.dart' as _i604;
import '../data/mappers/gym_membership_mapper.dart' as _i169;
import '../data/mappers/supplement_mapper.dart' as _i472;
import '../data/mappers/training_type_mapper.dart' as _i660;
import '../data/mappers/user_mapper.dart' as _i455;
import '../data/remote/account/account_cleanup_source.dart' as _i243;
import '../data/remote/app_config/app_config_source.dart' as _i892;
import '../data/remote/attendance/attendance_day_source.dart' as _i497;
import '../data/remote/membership/gym_membership_source.dart' as _i164;
import '../data/remote/supplement/health_source.dart' as _i531;
import '../data/remote/training_type/training_type_source.dart' as _i96;
import '../data/remote/user/user_source.dart' as _i905;
import '../presentation/helpers/locale_helper.dart' as _i214;
import '../presentation/helpers/onboarding_helper.dart' as _i654;
import '../service/account/account_cleanup_service.dart' as _i502;
import '../service/app_config/app_config_service.dart' as _i952;
import '../service/attendance/attendance_service.dart' as _i483;
import '../service/auth/auth_service.dart' as _i637;
import '../service/checking_update/checking_update_service.dart' as _i975;
import '../service/health/health_service.dart' as _i17;
import '../service/health_insights/body_composition_analyzer.dart' as _i903;
import '../service/health_insights/cardio_fitness_analyzer.dart' as _i965;
import '../service/health_insights/health_insights_service.dart' as _i442;
import '../service/health_insights/heart_rate_recovery_analyzer.dart' as _i973;
import '../service/health_insights/metabolic_analyzer.dart' as _i896;
import '../service/health_insights/metric_timeline_builder.dart' as _i680;
import '../service/health_insights/population_comparison_analyzer.dart'
    as _i917;
import '../service/health_insights/population_norms.dart' as _i727;
import '../service/health_insights/stress_index_analyzer.dart' as _i843;
import '../service/membership/gym_membership_service.dart' as _i874;
import '../service/membership/membership_reminder_service.dart' as _i993;
import '../service/user/user_service.dart' as _i729;
import '../service/workout/workout_service.dart' as _i425;
import 'app_router.dart' as _i313;
import 'app_version_status.dart' as _i477;
import 'firebase_module.dart' as _i616;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final firebaseModule = _$FirebaseModule();
  gh.factory<_i973.HeartRateRecoveryAnalyzer>(
    () => const _i973.HeartRateRecoveryAnalyzer(),
  );
  gh.factory<_i843.StressIndexAnalyzer>(
    () => const _i843.StressIndexAnalyzer(),
  );
  gh.factory<_i896.MetabolicAnalyzer>(() => const _i896.MetabolicAnalyzer());
  gh.factory<_i727.PopulationNorms>(() => const _i727.PopulationNorms());
  gh.factory<_i680.MetricTimelineBuilder>(
    () => const _i680.MetricTimelineBuilder(),
  );
  gh.factory<_i993.MembershipReminderService>(
    () => const _i993.MembershipReminderService(),
  );
  gh.factory<_i660.TrainingTypeMapper>(() => _i660.TrainingTypeMapper());
  gh.factory<_i604.AttendanceDayMapper>(() => _i604.AttendanceDayMapper());
  gh.factory<_i455.UserMapper>(() => _i455.UserMapper());
  gh.factory<_i169.GymMembershipMapper>(() => _i169.GymMembershipMapper());
  gh.factory<_i472.SupplementMapper>(() => _i472.SupplementMapper());
  gh.factory<_i710.AppConfigMapper>(() => _i710.AppConfigMapper());
  gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.firebaseAuth);
  gh.lazySingleton<_i974.FirebaseFirestore>(
    () => firebaseModule.firebaseFirestore,
  );
  gh.lazySingleton<_i477.AppVersionStatus>(() => _i477.AppVersionStatus());
  gh.lazySingleton<_i313.AppRouter>(() => _i313.AppRouter());
  gh.lazySingleton<_i66.HealthCacheStore>(() => _i66.HealthCacheStore());
  gh.lazySingleton<_i525.HealthKitSource>(() => const _i525.HealthKitSource());
  gh.factory<_i531.HealthSource>(
    () => _i531.HealthSource(
      gh<_i974.FirebaseFirestore>(),
      gh<_i472.SupplementMapper>(),
    ),
  );
  gh.factory<_i903.BodyCompositionAnalyzer>(
    () => _i903.BodyCompositionAnalyzer(gh<_i727.PopulationNorms>()),
  );
  gh.factory<_i917.PopulationComparisonAnalyzer>(
    () => _i917.PopulationComparisonAnalyzer(gh<_i727.PopulationNorms>()),
  );
  gh.factory<_i965.CardioFitnessAnalyzer>(
    () => _i965.CardioFitnessAnalyzer(gh<_i727.PopulationNorms>()),
  );
  gh.lazySingleton<_i58.HealthRepository>(
    () => _i315.AppleHealthRepository(
      gh<_i525.HealthKitSource>(),
      gh<_i66.HealthCacheStore>(),
    ),
  );
  gh.factory<_i96.TrainingTypeSource>(
    () => _i96.TrainingTypeSource(
      gh<_i974.FirebaseFirestore>(),
      gh<_i660.TrainingTypeMapper>(),
    ),
  );
  gh.factory<_i17.HealthService>(
    () => _i17.HealthService(gh<_i531.HealthSource>()),
  );
  gh.factory<_i164.GymMembershipSource>(
    () => _i164.GymMembershipSource(
      gh<_i974.FirebaseFirestore>(),
      gh<_i169.GymMembershipMapper>(),
    ),
  );
  gh.factory<_i637.AuthService>(
    () => _i637.AuthService(gh<_i59.FirebaseAuth>()),
  );
  gh.factory<_i905.UserSource>(
    () =>
        _i905.UserSource(gh<_i974.FirebaseFirestore>(), gh<_i455.UserMapper>()),
  );
  gh.factory<_i975.CheckingUpdateService>(
    () => _i975.CheckingUpdateService(gh<_i477.AppVersionStatus>()),
  );
  gh.factory<_i892.AppConfigSource>(
    () => _i892.AppConfigSource(
      gh<_i974.FirebaseFirestore>(),
      gh<_i710.AppConfigMapper>(),
    ),
  );
  gh.factory<_i497.AttendanceDaySource>(
    () => _i497.AttendanceDaySource(
      gh<_i974.FirebaseFirestore>(),
      gh<_i604.AttendanceDayMapper>(),
    ),
  );
  gh.factory<_i483.AttendanceService>(
    () => _i483.AttendanceService(gh<_i497.AttendanceDaySource>()),
  );
  gh.factory<_i952.AppConfigService>(
    () => _i952.AppConfigService(gh<_i892.AppConfigSource>()),
  );
  gh.factory<_i243.AccountCleanupSource>(
    () => _i243.AccountCleanupSource(gh<_i974.FirebaseFirestore>()),
  );
  gh.factory<_i829.HealthCubit>(
    () => _i829.HealthCubit(gh<_i17.HealthService>()),
  );
  gh.factory<_i729.UserService>(
    () => _i729.UserService(gh<_i905.UserSource>()),
  );
  gh.factory<_i176.AppVersionCubit>(
    () => _i176.AppVersionCubit(gh<_i952.AppConfigService>()),
  );
  gh.factory<_i384.MetricTimelineCubit>(
    () => _i384.MetricTimelineCubit(
      gh<_i58.HealthRepository>(),
      gh<_i680.MetricTimelineBuilder>(),
    ),
  );
  gh.factory<_i772.CheckingUpdateCubit>(
    () => _i772.CheckingUpdateCubit(gh<_i975.CheckingUpdateService>()),
  );
  gh.factory<_i425.WorkoutService>(
    () => _i425.WorkoutService(gh<_i96.TrainingTypeSource>()),
  );
  gh.factory<_i636.PhysicalOverviewDetailCubit>(
    () => _i636.PhysicalOverviewDetailCubit(
      gh<_i58.HealthRepository>(),
      gh<_i729.UserService>(),
      gh<_i637.AuthService>(),
      gh<_i680.MetricTimelineBuilder>(),
      gh<_i917.PopulationComparisonAnalyzer>(),
    ),
  );
  gh.factory<_i874.GymMembershipService>(
    () => _i874.GymMembershipService(gh<_i164.GymMembershipSource>()),
  );
  gh.factory<_i502.AccountCleanupService>(
    () => _i502.AccountCleanupService(
      gh<_i243.AccountCleanupSource>(),
      gh<_i58.HealthRepository>(),
    ),
  );
  gh.factory<_i442.HealthInsightsService>(
    () => _i442.HealthInsightsService(
      gh<_i58.HealthRepository>(),
      gh<_i729.UserService>(),
      gh<_i637.AuthService>(),
      gh<_i903.BodyCompositionAnalyzer>(),
      gh<_i965.CardioFitnessAnalyzer>(),
      gh<_i973.HeartRateRecoveryAnalyzer>(),
      gh<_i843.StressIndexAnalyzer>(),
      gh<_i896.MetabolicAnalyzer>(),
    ),
  );
  gh.factory<_i730.StatsCubit>(
    () => _i730.StatsCubit(
      gh<_i483.AttendanceService>(),
      gh<_i425.WorkoutService>(),
      gh<_i17.HealthService>(),
    ),
  );
  gh.factory<_i1060.CalendarCubit>(
    () => _i1060.CalendarCubit(
      gh<_i483.AttendanceService>(),
      gh<_i17.HealthService>(),
      gh<_i425.WorkoutService>(),
      gh<_i874.GymMembershipService>(),
      gh<_i993.MembershipReminderService>(),
    ),
  );
  gh.factory<_i963.SplashCubit>(
    () => _i963.SplashCubit(
      gh<_i952.AppConfigService>(),
      gh<_i654.OnboardingHelper>(),
      gh<_i214.LocaleHelper>(),
      gh<_i59.FirebaseAuth>(),
      gh<_i477.AppVersionStatus>(),
    ),
  );
  gh.factory<_i231.MembershipCubit>(
    () => _i231.MembershipCubit(
      gh<_i874.GymMembershipService>(),
      gh<_i729.UserService>(),
    ),
  );
  gh.factory<_i800.WorkoutCubit>(
    () => _i800.WorkoutCubit(gh<_i425.WorkoutService>()),
  );
  gh.factory<_i411.SettingsCubit>(
    () => _i411.SettingsCubit(gh<_i637.AuthService>(), gh<_i729.UserService>()),
  );
  gh.factory<_i548.AuthCubit>(
    () => _i548.AuthCubit(
      gh<_i637.AuthService>(),
      gh<_i729.UserService>(),
      gh<_i502.AccountCleanupService>(),
    ),
  );
  gh.factory<_i487.HealthInsightsCubit>(
    () => _i487.HealthInsightsCubit(gh<_i442.HealthInsightsService>()),
  );
  return getIt;
}

class _$FirebaseModule extends _i616.FirebaseModule {}
