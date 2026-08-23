import 'package:flutter/material.dart';

import '../design_system/theme/housely_theme.dart';
import '../features/access/access_draft.dart';
import 'housely_router.dart';

class HouselyApp extends StatefulWidget {
  const HouselyApp({
    this.initialLocation = '/welcome',
    this.accessDraft,
    super.key,
  });
  final String initialLocation;
  final AccessDraft? accessDraft;

  @override
  State<HouselyApp> createState() => _HouselyAppState();
}

class _HouselyAppState extends State<HouselyApp> {
  late final router = createHouselyRouter(
    initialLocation: widget.initialLocation,
    accessDraft: widget.accessDraft,
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
