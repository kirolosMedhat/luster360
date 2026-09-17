import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/events/presentation/event_management_screen.dart';
import '../../features/events/presentation/new_event_screen.dart';
import '../../features/capture/presentation/capture_screen.dart';
import '../../features/capture/presentation/booth_mode_screen.dart';
import '../../features/editor/presentation/editor_screen.dart';
import '../../features/gallery/presentation/local_gallery_screen.dart';
import '../../features/sharing/presentation/qr_share_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/storage_manager_screen.dart';
import '../../features/navigation/presentation/main_scaffold.dart';
import '../../features/admin/presentation/admin_console_screen.dart';
import '../../features/admin/presentation/device_fleet_screen.dart';
import '../../features/admin/presentation/events_data_screen.dart';
import '../../features/admin/presentation/statistics_screen.dart';
import '../../features/admin/presentation/user_management_screen.dart';
import '../../features/admin/presentation/storage_integration_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainScaffold(
        location: state.uri.toString(),
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/booth-mode',
          builder: (context, state) => const BoothModeScreen(),
        ),
        GoRoute(
          path: '/gallery',
          builder: (context, state) => const LocalGalleryScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminConsoleScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/events',
      builder: (context, state) => const EventManagementScreen(),
    ),
    GoRoute(
      path: '/events/new',
      builder: (context, state) => const NewEventScreen(),
    ),
    GoRoute(
      path: '/capture',
      builder: (context, state) => const CaptureScreen(),
    ),
    GoRoute(
      path: '/editor',
      builder: (context, state) => const EditorScreen(),
    ),
    GoRoute(
      path: '/share',
      builder: (context, state) {
        final code = state.uri.queryParameters['code'];
        return QrShareScreen(videoShortCode: code);
      },
    ),
    GoRoute(
      path: '/storage-manager',
      builder: (context, state) => const StorageManagerScreen(),
    ),
    GoRoute(
      path: '/admin/fleet',
      builder: (context, state) => const DeviceFleetScreen(),
    ),
    GoRoute(
      path: '/admin/events',
      builder: (context, state) => const EventsDataScreen(),
    ),
    GoRoute(
      path: '/admin/statistics',
      builder: (context, state) => const StatisticsScreen(),
    ),
    GoRoute(
      path: '/admin/users',
      builder: (context, state) => const UserManagementScreen(),
    ),
    GoRoute(
      path: '/admin/storage',
      builder: (context, state) => const StorageIntegrationScreen(),
    ),
  ],
);
