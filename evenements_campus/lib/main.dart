import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'core/routes/app_routes.dart';
import 'core/themes/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'data/datasources/local/app_database.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/event_repository_impl.dart';
import 'data/repositories/club_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/event_repository.dart';
import 'domain/repositories/club_repository.dart';
import 'domain/usecases/auth/login_usecase.dart';
import 'domain/usecases/auth/register_usecase.dart';
import 'domain/usecases/auth/forgot_password_usecase.dart';
import 'domain/usecases/auth/change_password_usecase.dart';
import 'domain/usecases/auth/update_profile_usecase.dart';
import 'domain/usecases/auth/update_email_usecase.dart';
import 'domain/usecases/auth/get_all_users_usecase.dart';
import 'domain/usecases/auth/delete_user_usecase.dart';
import 'domain/usecases/auth/delete_all_users_usecase.dart';
import 'domain/usecases/events/get_events_usecase.dart';
import 'domain/usecases/events/create_event_usecase.dart';
import 'domain/usecases/events/update_event_usecase.dart';
import 'domain/usecases/events/delete_event_usecase.dart';
import 'domain/usecases/events/register_for_event_usecase.dart';
import 'domain/usecases/events/unregister_from_event_usecase.dart';
import 'domain/usecases/clubs/get_clubs_usecase.dart';
import 'domain/usecases/clubs/join_club_usecase.dart';
import 'domain/usecases/clubs/create_club_usecase.dart';
import 'domain/usecases/clubs/update_club_usecase.dart';
import 'domain/usecases/clubs/delete_club_usecase.dart';
import 'domain/usecases/clubs/manage_members_usecase.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/event_viewmodel.dart';
import 'presentation/viewmodels/club_viewmodel.dart';
import 'presentation/viewmodels/notification_viewmodel.dart';
import 'services/notification_service.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  final appDatabase = AppDatabase();
  getIt.registerLazySingleton<AppDatabase>(() => appDatabase);

  getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt<AppDatabase>()));
  getIt.registerLazySingleton<EventRepository>(
      () => EventRepositoryImpl(getIt<AppDatabase>()));
  getIt.registerLazySingleton<ClubRepository>(
      () => ClubRepositoryImpl(getIt<AppDatabase>()));

  // ─── UseCases - Auth ─────────────────────────────────────────────
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
      () => SendResetCodeUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
      () => SendResetCodeWithRoleUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
      () => VerifyResetCodeUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
      () => ResetPasswordWithCodeUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
      () => UpdateProfileUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
      () => GetAllUsersUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
      () => ChangePasswordUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
      () => UpdateEmailUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
      () => DeleteUserUseCase(getIt<AuthRepository>())); // ✅ AJOUT
  getIt.registerLazySingleton(
      () => DeleteAllUsersUseCase(getIt<AuthRepository>())); // ✅ AJOUT

  // ─── UseCases - Events ───────────────────────────────────────────
  getIt.registerLazySingleton(
      () => GetUpcomingEventsUseCase(getIt<EventRepository>()));
  getIt.registerLazySingleton(
      () => GetEventsByTypeUseCase(getIt<EventRepository>()));
  getIt.registerLazySingleton(
      () => GetUserEventsUseCase(getIt<EventRepository>()));
  getIt.registerLazySingleton(
      () => CreateEventUseCase(getIt<EventRepository>()));
  getIt.registerLazySingleton(
      () => UpdateEventUseCase(getIt<EventRepository>()));
  getIt.registerLazySingleton(
      () => DeleteEventUseCase(getIt<EventRepository>()));
  getIt.registerLazySingleton(
      () => RegisterForEventUseCase(getIt<EventRepository>()));
  getIt.registerLazySingleton(
      () => UnregisterFromEventUseCase(getIt<EventRepository>()));

  // ─── UseCases - Clubs ────────────────────────────────────────────
  getIt
      .registerLazySingleton(() => GetAllClubsUseCase(getIt<ClubRepository>()));
  getIt.registerLazySingleton(
      () => GetUserClubsUseCase(getIt<ClubRepository>()));
  getIt.registerLazySingleton(() => JoinClubUseCase(getIt<ClubRepository>()));
  getIt.registerLazySingleton(() => LeaveClubUseCase(getIt<ClubRepository>()));
  getIt.registerLazySingleton(() => CreateClubUseCase(getIt<ClubRepository>()));
  getIt.registerLazySingleton(() => UpdateClubUseCase(getIt<ClubRepository>()));
  getIt.registerLazySingleton(() => DeleteClubUseCase(getIt<ClubRepository>()));
  getIt.registerLazySingleton(
      () => ManageMembersUseCase(getIt<ClubRepository>()));

  // ─── ViewModels ──────────────────────────────────────────────────
  getIt.registerFactory(() => AuthViewModel(
        loginUseCase: getIt<LoginUseCase>(),
        registerUseCase: getIt<RegisterUseCase>(),
        sendResetCodeUseCase: getIt<SendResetCodeUseCase>(),
        sendResetCodeWithRoleUseCase: getIt<SendResetCodeWithRoleUseCase>(),
        verifyResetCodeUseCase: getIt<VerifyResetCodeUseCase>(),
        resetPasswordWithCodeUseCase: getIt<ResetPasswordWithCodeUseCase>(),
        updateProfileUseCase: getIt<UpdateProfileUseCase>(),
        getAllUsersUseCase: getIt<GetAllUsersUseCase>(),
        changePasswordUseCase: getIt<ChangePasswordUseCase>(),
        updateEmailUseCase: getIt<UpdateEmailUseCase>(),
        deleteUserUseCase: getIt<DeleteUserUseCase>(), // ✅ AJOUT
        deleteAllUsersUseCase: getIt<DeleteAllUsersUseCase>(), // ✅ AJOUT
      ));
      
  getIt.registerFactory(() => EventViewModel(
        getUpcomingEventsUseCase: getIt<GetUpcomingEventsUseCase>(),
        getEventsByTypeUseCase: getIt<GetEventsByTypeUseCase>(),
        getUserEventsUseCase: getIt<GetUserEventsUseCase>(),
        registerForEventUseCase: getIt<RegisterForEventUseCase>(),
        createEventUseCase: getIt<CreateEventUseCase>(),
        updateEventUseCase: getIt<UpdateEventUseCase>(),
        deleteEventUseCase: getIt<DeleteEventUseCase>(),
        unregisterFromEventUseCase: getIt<UnregisterFromEventUseCase>(),
      ));
      
  getIt.registerFactory(() => ClubViewModel(
        getAllClubsUseCase: getIt<GetAllClubsUseCase>(),
        getUserClubsUseCase: getIt<GetUserClubsUseCase>(),
        joinClubUseCase: getIt<JoinClubUseCase>(),
        leaveClubUseCase: getIt<LeaveClubUseCase>(),
        createClubUseCase: getIt<CreateClubUseCase>(),
        updateClubUseCase: getIt<UpdateClubUseCase>(),
        deleteClubUseCase: getIt<DeleteClubUseCase>(),
        manageMembersUseCase: getIt<ManageMembersUseCase>(),
      ));
      
  getIt.registerFactory(() => NotificationViewModel(getIt<AppDatabase>()));
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('fr');

  static MyAppState? of(BuildContext context) {
    return context.findRootAncestorStateOfType<MyAppState>();
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('dark_mode_enabled') ?? false;
    final languageCode = prefs.getString('language') ?? 'fr';
    
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      _locale = Locale(languageCode);
    });
    
    _updateSystemNavigationBarColor(isDarkMode);
  }

  void _updateSystemNavigationBarColor(bool isDarkMode) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: isDarkMode ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  void refreshTheme() {
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<AuthViewModel>()),
        ChangeNotifierProvider(
            create: (_) => getIt<EventViewModel>()..loadUpcomingEvents()),
        ChangeNotifierProvider(
            create: (_) => getIt<ClubViewModel>()..loadClubs()),
        ChangeNotifierProvider(create: (_) => getIt<NotificationViewModel>()),
      ],
      child: MaterialApp.router(
        title: 'CampusEvent',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        locale: _locale,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr', 'FR'),
          Locale('en', 'US'),
          Locale('es', 'ES'),
        ],
        routerConfig: AppRoutes.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  final notificationService = NotificationService();
  await notificationService.initialize();
  setupDependencies();
  
  runApp(const MyApp());
}