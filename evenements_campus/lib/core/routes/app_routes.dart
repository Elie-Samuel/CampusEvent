import 'package:go_router/go_router.dart';
import '../../presentation/pages/splash_page.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/register_page.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/events_page.dart';
import '../../presentation/pages/admin_page.dart';
import '../../presentation/pages/event_detail_page.dart';
import '../../presentation/pages/create_event_page.dart';
import '../../presentation/pages/clubs_page.dart';
import '../../presentation/pages/club_detail_page.dart';
import '../../presentation/pages/profile_page.dart';
import '../../presentation/pages/conference_page.dart';
import '../../presentation/pages/forgot_password_page.dart';
import '../../presentation/pages/verify_code_page.dart';
import '../../presentation/pages/reset_password_page.dart';
import '../../presentation/pages/qr_scanner_page.dart';
import '../../presentation/pages/event_qr_page.dart';
import '../../presentation/pages/settings_page.dart';
import '../../presentation/pages/edit_conference_page.dart';
import '../../presentation/pages/notifications_page.dart';
import '../../presentation/pages/create_club_page.dart';
import '../../presentation/pages/edit_club_page.dart';
import '../../presentation/pages/create_conference_page.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/club.dart';

class AppRoutes {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        name: 'splash',
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        name: 'notifications',
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        name: 'settings',
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      // Dans app_routes.dart, ajoutez cette route après les autres

      GoRoute(
        name: 'admin',
        path: '/admin',
        builder: (context, state) => const AdminPage(),
      ),
      GoRoute(
        name: 'register',
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        name: 'editConference',
        path: '/edit-conference',
        builder: (context, state) {
          final event = state.extra as Event;
          return EditConferencePage(event: event);
        },
      ),
      GoRoute(
        name: 'forgotPassword',
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        name: 'verifyCode',
        path: '/verify-code',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            final email = extra['email'] ?? '';
            final role = extra['role'] ?? '';
            final code = extra['code'] ?? '';
            return VerifyCodePage(email: email, role: role);
          } else if (extra is String) {
            return VerifyCodePage(email: extra);
          }
          return VerifyCodePage(email: '');
        },
      ),
      GoRoute(
        name: 'resetPassword',
        path: '/reset-password',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            final email = extra['email'] ?? '';
            final code = extra['code'] ?? '';
            final role = extra['role'] ?? '';
            return ResetPasswordPage(email: email, code: code, role: role);
          }
          return ResetPasswordPage(email: '', code: '');
        },
      ),
      GoRoute(
        name: 'home',
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        name: 'events',
        path: '/events',
        builder: (context, state) => const EventsPage(),
      ),
      GoRoute(
        name: 'eventDetail',
        path: '/event/:id',
        builder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return EventDetailPage(eventId: eventId);
        },
      ),
      GoRoute(
        name: 'createEvent',
        path: '/create-event',
        builder: (context, state) => const CreateEventPage(),
      ),
      GoRoute(
        name: 'createConference',
        path: '/create-conference',
        builder: (context, state) => const CreateConferencePage(),
      ),
      GoRoute(
        name: 'clubs',
        path: '/clubs',
        builder: (context, state) => const ClubsPage(),
      ),
      GoRoute(
        name: 'clubDetail',
        path: '/club/:id',
        builder: (context, state) {
          final clubId = state.pathParameters['id']!;
          return ClubDetailPage(clubId: clubId);
        },
      ),
      GoRoute(
        name: 'createClub',
        path: '/create-club',
        builder: (context, state) => const CreateClubPage(),
      ),
      GoRoute(
        name: 'editClub',
        path: '/edit-club',
        builder: (context, state) {
          final club = state.extra as Club;
          return EditClubPage(club: club);
        },
      ),
      GoRoute(
        name: 'profile',
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        name: 'conference',
        path: '/conference',
        builder: (context, state) => const ConferencePage(),
      ),
      GoRoute(
        name: 'qrScanner',
        path: '/qr-scanner',
        builder: (context, state) => const QRScannerPage(),
      ),
      // Route manquante pour EventQRPage (optionnelle)
      GoRoute(
        name: 'eventQR',
        path: '/event-qr',
        builder: (context, state) {
          final event = state.extra as Event;
          return EventQRPage(event: event);
        },
      ),
    ],
  );
}