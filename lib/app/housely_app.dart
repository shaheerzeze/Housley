import 'package:flutter/material.dart';

import '../design_system/theme/housely_theme.dart';
import 'housely_router.dart';

class HouselyApp extends StatefulWidget {
  const HouselyApp({this.initialLocation = '/welcome', super.key});
  final String initialLocation;

  @override
  State<HouselyApp> createState() => _HouselyAppState();
}

class _HouselyAppState extends State<HouselyApp> {
  late final router = createHouselyRouter(
    initialLocation: widget.initialLocation,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Housely',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: HouselyTheme.light(),
      routerConfig: router,
    );
  }
}
