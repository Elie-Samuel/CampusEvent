// lib/core/di/injection.dart

import 'package:get_it/get_it.dart';
import '../../data/datasources/local/app_database.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../data/repositories/club_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/repositories/club_repository.dart';
import '../../domain/usecases/auth/update_email_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/change_password_usecase.dart';
import '../../domain/usecases/auth/forgot_password_usecase.dart';
import '../../domain/usecases/auth/update_profile_usecase.dart';
import '../../domain/usecases/auth/get_all_users_usecase.dart';
import '../../domain/usecases/auth/delete_user_usecase.dart';
import '../../domain/usecases/auth/delete_all_users_usecase.dart';
import '../../domain/usecases/events/get_events_usecase.dart';
import '../../domain/usecases/events/create_event_usecase.dart';
import '../../domain/usecases/events/update_event_usecase.dart';
import '../../domain/usecases/events/delete_event_usecase.dart';
import '../../domain/usecases/events/register_for_event_usecase.dart';
import '../../domain/usecases/events/unregister_from_event_usecase.dart';
import '../../domain/usecases/clubs/get_clubs_usecase.dart';
import '../../domain/usecases/clubs/create_club_usecase.dart';
import '../../domain/usecases/clubs/update_club_usecase.dart';
import '../../domain/usecases/clubs/delete_club_usecase.dart';
import '../../domain/usecases/clubs/join_club_usecase.dart';
import '../../domain/usecases/clubs/manage_members_usecase.dart';
import '../../presentation/viewmodels/auth_viewmodel.dart';
import '../../presentation/viewmodels/event_viewmodel.dart';
import '../../presentation/viewmodels/club_viewmodel.dart';
import '../../presentation/viewmodels/notification_viewmodel.dart';
import '../../services/notification_service.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // ─── Database ─────────────────────────────────────────────────────
  final db = AppDatabase();
  await db.database;
  getIt.registerSingleton<AppDatabase>(db);

  // ─── Repositories ────────────────────────────────────────────────
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt<AppDatabase>()));
  getIt.registerLazySingleton<EventRepository>(() => EventRepositoryImpl(getIt<AppDatabase>()));
  getIt.registerLazySingleton<ClubRepository>(() => ClubRepositoryImpl(getIt<AppDatabase>()));

  // ─── UseCases - Auth ─────────────────────────────────────────────
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SendResetCodeUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => UpdateEmailUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SendResetCodeWithRoleUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => VerifyResetCodeUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => ResetPasswordWithCodeUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => UpdateProfileUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GetAllUsersUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => DeleteUserUseCase(getIt<AuthRepository>())); // AJOUT
  getIt.registerLazySingleton(() => DeleteAllUsersUseCase(getIt<AuthRepository>())); // AJOUT

  // ─── UseCases - Events ───────────────────────────────────────────
  getIt.registerLazySingleton(() => GetUpcomingEventsUseCase(getIt<EventRepository>()));
  getIt.registerLazySingleton(() => GetEventsByTypeUseCase(getIt<EventRepository>()));
  getIt.registerLazySingleton(() => GetUserEventsUseCase(getIt<EventRepository>()));
  getIt.registerLazySingleton(() => CreateEventUseCase(getIt<EventRepository>()));
  getIt.registerLazySingleton(() => UpdateEventUseCase(getIt<EventRepository>()));
  getIt.registerLazySingleton(() => DeleteEventUseCase(getIt<EventRepository>()));
  getIt.registerLazySingleton(() => RegisterForEventUseCase(getIt<EventRepository>()));
  getIt.registerLazySingleton(() => UnregisterFromEventUseCase(getIt<EventRepository>()));

  // ─── UseCases - Clubs ────────────────────────────────────────────
  getIt.registerLazySingleton(() => GetAllClubsUseCase(getIt<ClubRepository>()));
  getIt.registerLazySingleton(() => GetUserClubsUseCase(getIt<ClubRepository>()));
  getIt.registerLazySingleton(() => CreateClubUseCase(getIt<ClubRepository>()));
  getIt.registerLazySingleton(() => UpdateClubUseCase(getIt<ClubRepository>()));
  getIt.registerLazySingleton(() => DeleteClubUseCase(getIt<ClubRepository>()));
  getIt.registerLazySingleton(() => JoinClubUseCase(getIt<ClubRepository>()));
  getIt.registerLazySingleton(() => LeaveClubUseCase(getIt<ClubRepository>()));
  getIt.registerLazySingleton(() => ManageMembersUseCase(getIt<ClubRepository>()));

  // ─── Services ────────────────────────────────────────────────────
  getIt.registerLazySingleton(() => NotificationService());

  // ─── ViewModels ──────────────────────────────────────────────────
  getIt.registerLazySingleton(() => AuthViewModel(
    loginUseCase: getIt<LoginUseCase>(),
    registerUseCase: getIt<RegisterUseCase>(),
    sendResetCodeUseCase: getIt<SendResetCodeUseCase>(),
    sendResetCodeWithRoleUseCase: getIt<SendResetCodeWithRoleUseCase>(),
    verifyResetCodeUseCase: getIt<VerifyResetCodeUseCase>(),
    resetPasswordWithCodeUseCase: getIt<ResetPasswordWithCodeUseCase>(),
    updateProfileUseCase: getIt<UpdateProfileUseCase>(),
    getAllUsersUseCase: getIt<GetAllUsersUseCase>(),
    changePasswordUseCase: getIt<ChangePasswordUseCase>(), 
    deleteUserUseCase: getIt<DeleteUserUseCase>(), // AJOUT
    deleteAllUsersUseCase: getIt<DeleteAllUsersUseCase>(), //AJOUT
  ));

  getIt.registerLazySingleton(() => NotificationViewModel(
    getIt<AppDatabase>(),
  ));

  getIt.registerLazySingleton(() => EventViewModel(
    getUpcomingEventsUseCase: getIt<GetUpcomingEventsUseCase>(),
    getEventsByTypeUseCase: getIt<GetEventsByTypeUseCase>(),
    getUserEventsUseCase: getIt<GetUserEventsUseCase>(),
    createEventUseCase: getIt<CreateEventUseCase>(),
    updateEventUseCase: getIt<UpdateEventUseCase>(),
    deleteEventUseCase: getIt<DeleteEventUseCase>(),
    registerForEventUseCase: getIt<RegisterForEventUseCase>(),
    unregisterFromEventUseCase: getIt<UnregisterFromEventUseCase>(),
  ));


  getIt.registerLazySingleton(() => ClubViewModel(
    getAllClubsUseCase: getIt<GetAllClubsUseCase>(),
    getUserClubsUseCase: getIt<GetUserClubsUseCase>(),
    createClubUseCase: getIt<CreateClubUseCase>(),
    updateClubUseCase: getIt<UpdateClubUseCase>(),
    deleteClubUseCase: getIt<DeleteClubUseCase>(),
    joinClubUseCase: getIt<JoinClubUseCase>(),
    leaveClubUseCase: getIt<LeaveClubUseCase>(),
    manageMembersUseCase: getIt<ManageMembersUseCase>(),
  ));
}