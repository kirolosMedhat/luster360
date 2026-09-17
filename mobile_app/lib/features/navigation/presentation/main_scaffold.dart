import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/luster_colors.dart';
import '../../auth/application/auth_controller.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;
  final String location;

  const MainScaffold({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final isAdmin = authState.user?.isAdmin ?? false;

    final tabs = [
      {'route': '/', 'icon': Icons.dashboard_rounded, 'label': 'Dashboard'},
      {'route': '/booth-mode', 'icon': Icons.camera_alt_rounded, 'label': 'Booth'},
      {'route': '/gallery', 'icon': Icons.collections_rounded, 'label': 'Gallery'},
      {'route': '/settings', 'icon': Icons.settings_rounded, 'label': 'Settings'},
      if (isAdmin)
        {'route': '/admin', 'icon': Icons.admin_panel_settings_rounded, 'label': 'Admin'},
    ];

    int currentIndex = 0;
    for (int i = 0; i < tabs.length; i++) {
      final route = tabs[i]['route'] as String;
      if (route == '/' && location == '/') {
        currentIndex = 0;
        break;
      } else if (route != '/' && location.startsWith(route)) {
        currentIndex = i;
        break;
      }
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: LusterColors.panel,
          border: Border(
            top: BorderSide(color: LusterColors.border, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(tabs.length, (index) {
                final tab = tabs[index];
                final isSelected = currentIndex == index;
                final color = isSelected ? LusterColors.primaryBlue : LusterColors.textMuted;

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      final targetRoute = tab['route'] as String;
                      if (location != targetRoute) {
                        context.go(targetRoute);
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tab['icon'] as IconData,
                          color: color,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab['label'] as String,
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
