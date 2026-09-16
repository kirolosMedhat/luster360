import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/events/presentation/event_management_screen.dart';
import '../../features/capture/presentation/capture_screen.dart';
import '../../features/capture/presentation/booth_mode_screen.dart';
import '../../features/editor/presentation/editor_screen.dart';
import '../../features/gallery/presentation/local_gallery_screen.dart';
import '../../features/sharing/presentation/qr_share_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/storage_manager_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/events',
      builder: (context, state) => const EventManagementScreen(),
    ),
    GoRoute(
      path: '/capture',
      builder: (context, state) => const CaptureScreen(),
    ),
    GoRoute(
      path: '/booth-mode',
      builder: (context, state) => const BoothModeScreen(),
    ),
    GoRoute(
      path: '/editor',
      builder: (context, state) => const EditorScreen(),
    ),
    GoRoute(
      path: '/gallery',
      builder: (context, state) => const LocalGalleryScreen(),
    ),
    GoRoute(
      path: '/share',
      builder: (context, state) {
        final code = state.uri.queryParameters['code'];
        return QrShareScreen(videoShortCode: code);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/storage-manager',
      builder: (context, state) => const StorageManagerScreen(),
    ),
  ],
);
