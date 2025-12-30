import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_session.dart';
import 'core/ble/ble_readiness_controller.dart';
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
        theme: AppTheme.base(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        // PARITY: Enable automatic locale resolution based on system language
        // Flutter automatically detects system locale and matches it to supported locales
        // We use a custom callback to handle Chinese variants (zh_TW -> zh_Hant)
        localeResolutionCallback: (locale, supportedLocales) {
          if (locale == null) {
            // If no locale provided, use first supported (usually 'en')
            return supportedLocales.first;
          }

          // Exact match: language + country + script
          for (final supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode &&
                supportedLocale.scriptCode == locale.scriptCode) {
              return supportedLocale;
            }
          }

          // Special handling for Chinese variants
          // PARITY: reef-b-app only has Traditional Chinese (values-zh-rTW), no Simplified Chinese
          if (locale.languageCode == 'zh') {
            // Check for Traditional Chinese (zh_TW, zh_HK, zh_Hant)
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
            // Simplified Chinese (zh_CN, zh) - fallback to Traditional Chinese
            // PARITY: reef-b-app only has Traditional Chinese, so we use it as fallback
            for (final supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == 'zh' &&
                  supportedLocale.scriptCode == 'Hant') {
                return supportedLocale;
              }
            }
          }

          // Language code match: find any locale with the same language code
          for (final supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }

          // Fallback to first supported locale (usually 'en')
          return supportedLocales.first;
        },
        home: const SplashPage(),
      ),
    );
  }
}
