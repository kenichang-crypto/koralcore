import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'application/common/app_context.dart';
import 'application/common/app_session.dart';
import 'application/system/ble_readiness_controller.dart';
import 'ui/theme/reef_theme.dart';
import 'ui/app/main_scaffold.dart';
import 'ui/app/navigation_controller.dart';
import 'ui/features/device/controllers/device_list_controller.dart';
import 'package:koralcore/l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KoralCoreApp());
}

class KoralCoreApp extends StatefulWidget {
  const KoralCoreApp({super.key});

  @override
  State<KoralCoreApp> createState() => _KoralCoreAppState();
}

class _KoralCoreAppState extends State<KoralCoreApp> {
  late final AppContext _appContext = AppContext.bootstrap();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppContext>.value(value: _appContext),
        ChangeNotifierProvider<AppSession>(
          create: (_) => AppSession(context: _appContext),
        ),
        ChangeNotifierProvider<NavigationController>(
          create: (_) => NavigationController(),
        ),
        ChangeNotifierProvider<DeviceListController>(
          create: (_) => DeviceListController(context: _appContext),
        ),
        ChangeNotifierProvider<BleReadinessController>(
          create: (_) => BleReadinessController(),
        ),
      ],
      child: MaterialApp(
        title: 'KoralCore',
        theme: ReefTheme.base(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MainScaffold(),
      ),
    );
  }
}
