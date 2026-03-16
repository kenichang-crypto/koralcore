import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_session.dart';
import 'app/system/ble_readiness_controller.dart';
import 'shared/theme/app_theme.dart';
import 'app/navigation_controller.dart';
import 'features/device/presentation/controllers/device_list_controller.dart';
import 'features/splash/presentation/pages/splash_page.dart';
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
  bool _blePermissionsRequested = false;

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
        ChangeNotifierProvider<BleReadinessController>(
          create: (_) => BleReadinessController(),
        ),
        ChangeNotifierProvider<DeviceListController>(
          create: (context) => DeviceListController(
            context: _appContext,
            session: context.read<AppSession>(),
            bleReadinessController: context.read<BleReadinessController>(),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          if (!_blePermissionsRequested) {
            _blePermissionsRequested = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<BleReadinessController>().requestPermissions();
            });
          }
          return MaterialApp(
            title: 'KoralCore',
            theme: AppTheme.base(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            localeResolutionCallback: (locale, supportedLocales) {
              if (locale == null) {
                return supportedLocales.first;
              }
              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode &&
                    supportedLocale.countryCode == locale.countryCode &&
                    supportedLocale.scriptCode == locale.scriptCode) {
                  return supportedLocale;
                }
              }
              if (locale.languageCode == 'zh') {
                if (locale.scriptCode == 'Hant' ||
                    locale.countryCode == 'TW' ||
                    locale.countryCode == 'HK') {
                  for (final supportedLocale in supportedLocales) {
                    if (supportedLocale.languageCode == 'zh' &&
                        supportedLocale.scriptCode == 'Hant') {
                      return supportedLocale;
                    }
                  }
                }
                for (final supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == 'zh' &&
                      supportedLocale.scriptCode == 'Hant') {
                    return supportedLocale;
                  }
                }
              }
              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            home: const SplashPage(),
          );
        },
      ),
    );
  }
}
