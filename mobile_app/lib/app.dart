import 'package:flutter/material.dart';
import 'core/theme/luster_theme.dart';
import 'core/routing/app_router.dart';
import 'features/synchronization/application/device_presence_service.dart';

class Luster360App extends StatefulWidget {
  const Luster360App({super.key});

  @override
  State<Luster360App> createState() => _Luster360AppState();
}

class _Luster360AppState extends State<Luster360App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start presence stream on app launch
    DevicePresenceService.instance.startPresenceStream();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Stop presence stream when app is disposed
    DevicePresenceService.instance.stopPresenceStream();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App brought to foreground -> immediately send ONLINE heartbeat
      DevicePresenceService.instance.startPresenceStream();
    } else if (state == AppLifecycleState.paused ||
               state == AppLifecycleState.inactive ||
               state == AppLifecycleState.detached) {
      // App minimized or closed -> immediately send OFFLINE disconnect beacon
      DevicePresenceService.instance.stopPresenceStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Luster 360',
      debugShowCheckedModeBanner: false,
      theme: LusterTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
