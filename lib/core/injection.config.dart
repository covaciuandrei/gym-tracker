// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../cubit/auth/auth_cubit.dart' as _i548;
import '../cubit/calendar/calendar_cubit.dart' as _i1060;
import '../cubit/health/health_cubit.dart' as _i829;
import '../cubit/settings/settings_cubit.dart' as _i411;
import '../cubit/stats/stats_cubit.dart' as _i730;
import '../cubit/workout/workout_cubit.dart' as _i800;
import '../data/mappers/attendance_day_mapper.dart' as _i604;
import '../data/mappers/supplement_mapper.dart' as _i472;
import '../data/mappers/training_type_mapper.dart' as _i660;
import '../data/remote/attendance/attendance_day_source.dart' as _i497;
import '../data/remote/supplement/health_source.dart' as _i531;
import '../data/remote/training_type/training_type_source.dart' as _i96;
import '../service/attendance/attendance_service.dart' as _i483;
import '../service/auth/auth_service.dart' as _i637;
import '../service/health/health_service.dart' as _i17;
import '../service/workout/workout_service.dart' as _i425;
import 'app_router.dart' as _i313;
import 'firebase_module.dart' as _i616;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final firebaseModule = _$FirebaseModule();
  gh.factory<_i411.SettingsCubit>(() => _i411.SettingsCubit());
  gh.factory<_i604.AttendanceDayMapper>(() => _i604.AttendanceDayMapper());
  gh.factory<_i472.SupplementMapper>(() => _i472.SupplementMapper());
  gh.factory<_i660.TrainingTypeMapper>(() => _i660.TrainingTypeMapper());
  gh.lazySingleton<_i313.AppRouter>(() => _i313.AppRouter());
  gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.firebaseAuth);
  gh.factory<_i637.AuthService>(
    () => _i637.AuthService(gh<_i59.FirebaseAuth>()),
  );
  gh.factory<_i497.AttendanceDaySource>(
    () => _i497.AttendanceDaySource(gh<_i604.AttendanceDayMapper>()),
  );
  gh.factory<_i531.HealthSource>(
    () => _i531.HealthSource(gh<_i472.SupplementMapper>()),
  );
  gh.factory<_i483.AttendanceService>(
    () => _i483.AttendanceService(gh<_i497.AttendanceDaySource>()),
  );
  gh.factory<_i96.TrainingTypeSource>(
    () => _i96.TrainingTypeSource(gh<_i660.TrainingTypeMapper>()),
  );
  gh.factory<_i548.AuthCubit>(() => _i548.AuthCubit(gh<_i637.AuthService>()));
  gh.factory<_i425.WorkoutService>(
    () => _i425.WorkoutService(gh<_i96.TrainingTypeSource>()),
  );
  gh.factory<_i17.HealthService>(
    () => _i17.HealthService(gh<_i531.HealthSource>()),
  );
  gh.factory<_i1060.CalendarCubit>(
    () => _i1060.CalendarCubit(
      gh<_i483.AttendanceService>(),
      gh<_i17.HealthService>(),
      gh<_i425.WorkoutService>(),
    ),
  );
  gh.factory<_i800.WorkoutCubit>(
    () => _i800.WorkoutCubit(gh<_i425.WorkoutService>()),
  );
  gh.factory<_i829.HealthCubit>(
    () => _i829.HealthCubit(gh<_i17.HealthService>()),
  );
  gh.factory<_i730.StatsCubit>(
    () => _i730.StatsCubit(
      gh<_i483.AttendanceService>(),
      gh<_i425.WorkoutService>(),
      gh<_i17.HealthService>(),
    ),
  );
  return getIt;
}

class _$FirebaseModule extends _i616.FirebaseModule {}
