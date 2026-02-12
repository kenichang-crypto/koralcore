import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('id'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('th'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'KoralCore'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth'**
  String get tabBluetooth;

  /// No description provided for @tabDevice.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get tabDevice;

  /// No description provided for @homeStatusConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected to {device}'**
  String homeStatusConnected(String device);

  /// No description provided for @homeStatusDisconnected.
  ///
  /// In en, this message translates to:
  /// **'No active device'**
  String get homeStatusDisconnected;

  /// No description provided for @homeConnectedCopy.
  ///
  /// In en, this message translates to:
  /// **'Manage dosing and lighting right from your phone.'**
  String get homeConnectedCopy;

  /// No description provided for @homeConnectCta.
  ///
  /// In en, this message translates to:
  /// **'Connect a device'**
  String get homeConnectCta;

  /// No description provided for @homeNoDeviceCopy.
  ///
  /// In en, this message translates to:
  /// **'Pair your Koral doser or LED controller to manage schedules and lighting.'**
  String get homeNoDeviceCopy;

  /// No description provided for @sectionDosingTitle.
  ///
  /// In en, this message translates to:
  /// **'Dosing'**
  String get sectionDosingTitle;

  /// No description provided for @sectionLedTitle.
  ///
  /// In en, this message translates to:
  /// **'Lighting'**
  String get sectionLedTitle;

  /// No description provided for @bleDisconnectedWarning.
  ///
  /// In en, this message translates to:
  /// **'Please enable Bluetooth.'**
  String get bleDisconnectedWarning;

  /// No description provided for @bleGuardDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth required'**
  String get bleGuardDialogTitle;

  /// No description provided for @bleGuardDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enable Bluetooth.'**
  String get bleGuardDialogMessage;

  /// No description provided for @bleGuardDialogButton.
  ///
  /// In en, this message translates to:
  /// **'I understood'**
  String get bleGuardDialogButton;

  /// No description provided for @bleOnboardingPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Bluetooth access'**
  String get bleOnboardingPermissionTitle;

  /// No description provided for @bleOnboardingPermissionCopy.
  ///
  /// In en, this message translates to:
  /// **'We use Bluetooth to discover and control your Koral hardware nearby.'**
  String get bleOnboardingPermissionCopy;

  /// No description provided for @bleOnboardingPermissionCta.
  ///
  /// In en, this message translates to:
  /// **'Allow access'**
  String get bleOnboardingPermissionCta;

  /// No description provided for @bleOnboardingSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Permission required in Settings'**
  String get bleOnboardingSettingsTitle;

  /// No description provided for @bleOnboardingSettingsCopy.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth access was previously denied. Open system settings to enable it.'**
  String get bleOnboardingSettingsCopy;

  /// No description provided for @bleOnboardingSettingsCta.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get bleOnboardingSettingsCta;

  /// No description provided for @bleOnboardingLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow location access'**
  String get bleOnboardingLocationTitle;

  /// No description provided for @bleOnboardingLocationCopy.
  ///
  /// In en, this message translates to:
  /// **'Android requires location access on older versions to scan for Bluetooth devices.'**
  String get bleOnboardingLocationCopy;

  /// No description provided for @bleOnboardingBluetoothOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on Bluetooth'**
  String get bleOnboardingBluetoothOffTitle;

  /// No description provided for @bleOnboardingBluetoothOffCopy.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth must stay on to keep scanning and control your devices.'**
  String get bleOnboardingBluetoothOffCopy;

  /// No description provided for @bleOnboardingBluetoothCta.
  ///
  /// In en, this message translates to:
  /// **'Open Bluetooth settings'**
  String get bleOnboardingBluetoothCta;

  /// No description provided for @bleOnboardingUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth unavailable'**
  String get bleOnboardingUnavailableTitle;

  /// No description provided for @bleOnboardingUnavailableCopy.
  ///
  /// In en, this message translates to:
  /// **'This device does not expose a Bluetooth radio that KoralCore can use.'**
  String get bleOnboardingUnavailableCopy;

  /// No description provided for @bleOnboardingRetryCta.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get bleOnboardingRetryCta;

  /// No description provided for @bleOnboardingLearnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get bleOnboardingLearnMore;

  /// No description provided for @bleOnboardingSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Why KoralCore needs Bluetooth'**
  String get bleOnboardingSheetTitle;

  /// No description provided for @bleOnboardingSheetDescription.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth powers discovery and control of your dosing and lighting hardware. Here\'s what happens once you grant access.'**
  String get bleOnboardingSheetDescription;

  /// No description provided for @bleOnboardingSheetSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Find nearby devices'**
  String get bleOnboardingSheetSearchTitle;

  /// No description provided for @bleOnboardingSheetSearchCopy.
  ///
  /// In en, this message translates to:
  /// **'Scan for Reef Dose, Reef LED, and other Koral equipment around your tank.'**
  String get bleOnboardingSheetSearchCopy;

  /// No description provided for @bleOnboardingSheetControlTitle.
  ///
  /// In en, this message translates to:
  /// **'Control dosing and lighting'**
  String get bleOnboardingSheetControlTitle;

  /// No description provided for @bleOnboardingSheetControlCopy.
  ///
  /// In en, this message translates to:
  /// **'Sync schedules, send commands, and keep firmware up to date over a secure BLE link.'**
  String get bleOnboardingSheetControlCopy;

  /// No description provided for @bleOnboardingSheetFooter.
  ///
  /// In en, this message translates to:
  /// **'As soon as Bluetooth is ready we automatically resume scanning.'**
  String get bleOnboardingSheetFooter;

  /// No description provided for @bleOnboardingDisabledHint.
  ///
  /// In en, this message translates to:
  /// **'Grant Bluetooth access to start scanning.'**
  String get bleOnboardingDisabledHint;

  /// No description provided for @bleOnboardingBlockedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth setup required'**
  String get bleOnboardingBlockedEmptyTitle;

  /// No description provided for @bleOnboardingBlockedEmptyCopy.
  ///
  /// In en, this message translates to:
  /// **'Allow Bluetooth access or turn it on to discover your reef hardware.'**
  String get bleOnboardingBlockedEmptyCopy;

  /// No description provided for @bluetoothHeader.
  ///
  /// In en, this message translates to:
  /// **'Nearby devices'**
  String get bluetoothHeader;

  /// No description provided for @bluetoothScanCta.
  ///
  /// In en, this message translates to:
  /// **'Scan for devices'**
  String get bluetoothScanCta;

  /// No description provided for @bluetoothScanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get bluetoothScanning;

  /// No description provided for @bluetoothEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No devices found yet.'**
  String get bluetoothEmptyState;

  /// No description provided for @bluetoothConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get bluetoothConnect;

  /// No description provided for @bluetoothRearrangement.
  ///
  /// In en, this message translates to:
  /// **'Rearrangement'**
  String get bluetoothRearrangement;

  /// No description provided for @bluetoothOtherDevice.
  ///
  /// In en, this message translates to:
  /// **'Other Devices'**
  String get bluetoothOtherDevice;

  /// No description provided for @bluetoothNoOtherDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'No devices found.'**
  String get bluetoothNoOtherDeviceTitle;

  /// No description provided for @bluetoothNoOtherDeviceContent.
  ///
  /// In en, this message translates to:
  /// **'Tap on the top right to rescan nearby devices.'**
  String get bluetoothNoOtherDeviceContent;

  /// No description provided for @bluetoothDisconnectDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Do you want to disconnect Bluetooth?'**
  String get bluetoothDisconnectDialogContent;

  /// No description provided for @bluetoothDisconnectDialogPositive.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get bluetoothDisconnectDialogPositive;

  /// No description provided for @bluetoothDisconnectDialogNegative.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get bluetoothDisconnectDialogNegative;

  /// No description provided for @deviceHeader.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get deviceHeader;

  /// No description provided for @deviceEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No devices currently available.'**
  String get deviceEmptyTitle;

  /// No description provided for @deviceEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the Bluetooth tab to discover hardware.'**
  String get deviceEmptySubtitle;

  /// No description provided for @deviceInSinkEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'The tank currently has no devices.'**
  String get deviceInSinkEmptyTitle;

  /// No description provided for @deviceInSinkEmptyContent.
  ///
  /// In en, this message translates to:
  /// **'Add devices from the Bluetooth list below.'**
  String get deviceInSinkEmptyContent;

  /// No description provided for @deviceStateConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get deviceStateConnected;

  /// No description provided for @deviceStateDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get deviceStateDisconnected;

  /// No description provided for @deviceStateConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get deviceStateConnecting;

  /// No description provided for @deviceActionConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get deviceActionConnect;

  /// No description provided for @deviceActionDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get deviceActionDisconnect;

  /// No description provided for @deviceDeleteMode.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deviceDeleteMode;

  /// No description provided for @deviceSelectMode.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get deviceSelectMode;

  /// No description provided for @deviceDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **''**
  String get deviceDeleteConfirmTitle;

  /// No description provided for @deviceDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete the selected device?'**
  String get deviceDeleteConfirmMessage;

  /// No description provided for @deviceDeleteConfirmPrimary.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deviceDeleteConfirmPrimary;

  /// No description provided for @deviceDeleteConfirmSecondary.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deviceDeleteConfirmSecondary;

  /// No description provided for @deviceDeleteLedMasterTitle.
  ///
  /// In en, this message translates to:
  /// **'Master-Slave Settings'**
  String get deviceDeleteLedMasterTitle;

  /// No description provided for @deviceDeleteLedMasterContent.
  ///
  /// In en, this message translates to:
  /// **'To delete the master light, please modify the master-slave settings and set other slave lights as master.'**
  String get deviceDeleteLedMasterContent;

  /// No description provided for @deviceDeleteLedMasterPositive.
  ///
  /// In en, this message translates to:
  /// **'I understood'**
  String get deviceDeleteLedMasterPositive;

  /// No description provided for @deviceActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete selected'**
  String get deviceActionDelete;

  /// No description provided for @deviceSelectionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String deviceSelectionCount(int count);

  /// No description provided for @toastDeleteDeviceSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Successfully deleted device.'**
  String get toastDeleteDeviceSuccessful;

  /// No description provided for @toastDeleteDeviceFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete device.'**
  String get toastDeleteDeviceFailed;

  /// No description provided for @dosingHeader.
  ///
  /// In en, this message translates to:
  /// **'Dosing'**
  String get dosingHeader;

  /// No description provided for @dosingSubHeader.
  ///
  /// In en, this message translates to:
  /// **'Control daily dosing routines.'**
  String get dosingSubHeader;

  /// No description provided for @dosingEntrySchedule.
  ///
  /// In en, this message translates to:
  /// **'Edit schedule'**
  String get dosingEntrySchedule;

  /// No description provided for @dosingEntryManual.
  ///
  /// In en, this message translates to:
  /// **'Manual dose'**
  String get dosingEntryManual;

  /// No description provided for @dosingEntryCalibration.
  ///
  /// In en, this message translates to:
  /// **'Calibration'**
  String get dosingEntryCalibration;

  /// No description provided for @dosingEntryHistory.
  ///
  /// In en, this message translates to:
  /// **'Dose history'**
  String get dosingEntryHistory;

  /// No description provided for @dosingScheduleAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add schedule'**
  String get dosingScheduleAddButton;

  /// No description provided for @dosingScheduleEditTitleNew.
  ///
  /// In en, this message translates to:
  /// **'New schedule'**
  String get dosingScheduleEditTitleNew;

  /// No description provided for @dosingScheduleEditTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit schedule'**
  String get dosingScheduleEditTitleEdit;

  /// No description provided for @dosingScheduleEditDescription.
  ///
  /// In en, this message translates to:
  /// **'Configure dosing windows for this pump head.'**
  String get dosingScheduleEditDescription;

  /// No description provided for @dosingScheduleEditTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Schedule type'**
  String get dosingScheduleEditTypeLabel;

  /// No description provided for @dosingScheduleEditDoseLabel.
  ///
  /// In en, this message translates to:
  /// **'Dose per event'**
  String get dosingScheduleEditDoseLabel;

  /// No description provided for @dosingScheduleEditDoseHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the amount in milliliters.'**
  String get dosingScheduleEditDoseHint;

  /// No description provided for @dosingScheduleEditEventsLabel.
  ///
  /// In en, this message translates to:
  /// **'Events per day'**
  String get dosingScheduleEditEventsLabel;

  /// No description provided for @dosingScheduleEditStartTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'First dose'**
  String get dosingScheduleEditStartTimeLabel;

  /// No description provided for @dosingScheduleEditWindowStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Window start'**
  String get dosingScheduleEditWindowStartLabel;

  /// No description provided for @dosingScheduleEditWindowEndLabel.
  ///
  /// In en, this message translates to:
  /// **'Window end'**
  String get dosingScheduleEditWindowEndLabel;

  /// No description provided for @dosingScheduleEditWindowEventsLabel.
  ///
  /// In en, this message translates to:
  /// **'Events per window'**
  String get dosingScheduleEditWindowEventsLabel;

  /// No description provided for @dosingScheduleEditRecurrenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Recurrence'**
  String get dosingScheduleEditRecurrenceLabel;

  /// No description provided for @dosingScheduleEditEnabledToggle.
  ///
  /// In en, this message translates to:
  /// **'Enable schedule'**
  String get dosingScheduleEditEnabledToggle;

  /// No description provided for @dosingScheduleEditSave.
  ///
  /// In en, this message translates to:
  /// **'Save schedule'**
  String get dosingScheduleEditSave;

  /// No description provided for @dosingScheduleEditSuccess.
  ///
  /// In en, this message translates to:
  /// **'Schedule saved.'**
  String get dosingScheduleEditSuccess;

  /// No description provided for @dosingScheduleEditInvalidDose.
  ///
  /// In en, this message translates to:
  /// **'Enter a dose greater than zero.'**
  String get dosingScheduleEditInvalidDose;

  /// No description provided for @dosingScheduleEditInvalidWindow.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time.'**
  String get dosingScheduleEditInvalidWindow;

  /// No description provided for @dosingScheduleEditTemplateDaily.
  ///
  /// In en, this message translates to:
  /// **'Use daily average template'**
  String get dosingScheduleEditTemplateDaily;

  /// No description provided for @dosingScheduleEditTemplateCustom.
  ///
  /// In en, this message translates to:
  /// **'Use custom window template'**
  String get dosingScheduleEditTemplateCustom;

  /// No description provided for @dosingManualPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Run an on-demand dose from this pump head.'**
  String get dosingManualPageSubtitle;

  /// No description provided for @dosingManualDoseInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Dose amount'**
  String get dosingManualDoseInputLabel;

  /// No description provided for @dosingManualDoseInputHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter the dosing volume.'**
  String get dosingManualDoseInputHint;

  /// No description provided for @dosingManualConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Send manual dose?'**
  String get dosingManualConfirmTitle;

  /// No description provided for @dosingManualConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This dose will start immediately. Make sure your dosing line is ready.'**
  String get dosingManualConfirmMessage;

  /// No description provided for @dosingManualInvalidDose.
  ///
  /// In en, this message translates to:
  /// **'Each dosing volume cannot be less than 1ml.'**
  String get dosingManualInvalidDose;

  /// No description provided for @ledHeader.
  ///
  /// In en, this message translates to:
  /// **'Lighting'**
  String get ledHeader;

  /// No description provided for @ledSubHeader.
  ///
  /// In en, this message translates to:
  /// **'Tune spectrums and schedules.'**
  String get ledSubHeader;

  /// No description provided for @ledEntryIntensity.
  ///
  /// In en, this message translates to:
  /// **'Adjust intensity'**
  String get ledEntryIntensity;

  /// No description provided for @ledIntensityEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tune output for each lighting channel.'**
  String get ledIntensityEntrySubtitle;

  /// No description provided for @ledEntryPrograms.
  ///
  /// In en, this message translates to:
  /// **'Scenes & programs'**
  String get ledEntryPrograms;

  /// No description provided for @ledEntryManual.
  ///
  /// In en, this message translates to:
  /// **'Manual control'**
  String get ledEntryManual;

  /// No description provided for @ledEntryRecords.
  ///
  /// In en, this message translates to:
  /// **'Open records'**
  String get ledEntryRecords;

  /// No description provided for @ledEntryRecordsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review lighting time points synced from Reef B.'**
  String get ledEntryRecordsSubtitle;

  /// No description provided for @ledChannelBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get ledChannelBlue;

  /// No description provided for @ledChannelRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get ledChannelRed;

  /// No description provided for @ledChannelGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get ledChannelGreen;

  /// No description provided for @ledChannelPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get ledChannelPurple;

  /// No description provided for @ledChannelUv.
  ///
  /// In en, this message translates to:
  /// **'UV'**
  String get ledChannelUv;

  /// No description provided for @ledChannelWarmWhite.
  ///
  /// In en, this message translates to:
  /// **'Warm white'**
  String get ledChannelWarmWhite;

  /// No description provided for @ledChannelMoon.
  ///
  /// In en, this message translates to:
  /// **'Moonlight'**
  String get ledChannelMoon;

  /// No description provided for @ledScheduleAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add schedule'**
  String get ledScheduleAddButton;

  /// No description provided for @ledScheduleEditTitleNew.
  ///
  /// In en, this message translates to:
  /// **'New lighting schedule'**
  String get ledScheduleEditTitleNew;

  /// No description provided for @ledScheduleEditTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit lighting schedule'**
  String get ledScheduleEditTitleEdit;

  /// No description provided for @ledScheduleEditDescription.
  ///
  /// In en, this message translates to:
  /// **'Configure time windows and intensity levels.'**
  String get ledScheduleEditDescription;

  /// No description provided for @ledScheduleEditNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Schedule name'**
  String get ledScheduleEditNameLabel;

  /// No description provided for @ledScheduleEditNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a label'**
  String get ledScheduleEditNameHint;

  /// No description provided for @ledScheduleEditInvalidName.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty.'**
  String get ledScheduleEditInvalidName;

  /// No description provided for @ledScheduleEditTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Schedule type'**
  String get ledScheduleEditTypeLabel;

  /// No description provided for @ledScheduleEditStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get ledScheduleEditStartLabel;

  /// No description provided for @ledScheduleEditEndLabel.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get ledScheduleEditEndLabel;

  /// No description provided for @ledScheduleEditRecurrenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Recurrence'**
  String get ledScheduleEditRecurrenceLabel;

  /// No description provided for @ledScheduleEditEnabledToggle.
  ///
  /// In en, this message translates to:
  /// **'Enable schedule'**
  String get ledScheduleEditEnabledToggle;

  /// No description provided for @ledScheduleEditChannelsHeader.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get ledScheduleEditChannelsHeader;

  /// No description provided for @ledScheduleEditChannelWhite.
  ///
  /// In en, this message translates to:
  /// **'Cool white'**
  String get ledScheduleEditChannelWhite;

  /// No description provided for @ledScheduleEditChannelBlue.
  ///
  /// In en, this message translates to:
  /// **'Royal blue'**
  String get ledScheduleEditChannelBlue;

  /// No description provided for @ledScheduleEditSave.
  ///
  /// In en, this message translates to:
  /// **'Save schedule'**
  String get ledScheduleEditSave;

  /// No description provided for @ledScheduleEditSuccess.
  ///
  /// In en, this message translates to:
  /// **'Settings successful.'**
  String get ledScheduleEditSuccess;

  /// No description provided for @ledScheduleEditInvalidWindow.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time.'**
  String get ledScheduleEditInvalidWindow;

  /// No description provided for @ledControlTitle.
  ///
  /// In en, this message translates to:
  /// **'Intensity & spectrum'**
  String get ledControlTitle;

  /// No description provided for @ledControlSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust each lighting channel, then apply when ready.'**
  String get ledControlSubtitle;

  /// No description provided for @ledControlChannelsSection.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get ledControlChannelsSection;

  /// No description provided for @ledControlValueLabel.
  ///
  /// In en, this message translates to:
  /// **'{percent}% output'**
  String ledControlValueLabel(int percent);

  /// No description provided for @ledControlApplySuccess.
  ///
  /// In en, this message translates to:
  /// **'LED settings updated.'**
  String get ledControlApplySuccess;

  /// No description provided for @ledControlEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No adjustable LED channels yet.'**
  String get ledControlEmptyState;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @actionApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get actionApply;

  /// Cancel action button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// Confirm action button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionConfirm;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @errorDeviceBusy.
  ///
  /// In en, this message translates to:
  /// **'This pump head is currently dosing, please try again later.'**
  String get errorDeviceBusy;

  /// No description provided for @errorNoDevice.
  ///
  /// In en, this message translates to:
  /// **'Device not connected'**
  String get errorNoDevice;

  /// No description provided for @errorNotSupported.
  ///
  /// In en, this message translates to:
  /// **'This action is not supported on the connected device.'**
  String get errorNotSupported;

  /// No description provided for @errorInvalidParam.
  ///
  /// In en, this message translates to:
  /// **'Invalid parameters for this use case.'**
  String get errorInvalidParam;

  /// No description provided for @errorTransport.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth transport error. Check the signal and retry.'**
  String get errorTransport;

  /// No description provided for @errorSinkFull.
  ///
  /// In en, this message translates to:
  /// **'Tank is full.'**
  String get errorSinkFull;

  /// No description provided for @errorSinkGroupsFull.
  ///
  /// In en, this message translates to:
  /// **'All LED groups in this sink are full. Maximum 4 devices per group.'**
  String get errorSinkGroupsFull;

  /// No description provided for @errorConnectLimit.
  ///
  /// In en, this message translates to:
  /// **'Maximum 1 device can be connected simultaneously.'**
  String get errorConnectLimit;

  /// No description provided for @errorLedMasterCannotDelete.
  ///
  /// In en, this message translates to:
  /// **'To delete the master light, please modify the master-slave settings and set other slave lights as the master.'**
  String get errorLedMasterCannotDelete;

  /// No description provided for @errorDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete device.'**
  String get errorDeleteFailed;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please retry.'**
  String get errorGeneric;

  /// No description provided for @snackbarDeviceRemoved.
  ///
  /// In en, this message translates to:
  /// **'Successfully deleted device.'**
  String get snackbarDeviceRemoved;

  /// No description provided for @snackbarDeviceConnected.
  ///
  /// In en, this message translates to:
  /// **'Connection successful.'**
  String get snackbarDeviceConnected;

  /// No description provided for @snackbarDeviceDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Device disconnected.'**
  String get snackbarDeviceDisconnected;

  /// No description provided for @dosingPumpHeadsHeader.
  ///
  /// In en, this message translates to:
  /// **'Pump heads'**
  String get dosingPumpHeadsHeader;

  /// No description provided for @dosingPumpHeadsSubheader.
  ///
  /// In en, this message translates to:
  /// **'Tap a head to review flow and totals.'**
  String get dosingPumpHeadsSubheader;

  /// No description provided for @dosingPumpHeadSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Head {head}'**
  String dosingPumpHeadSummaryTitle(String head);

  /// No description provided for @dosingPumpHeadStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get dosingPumpHeadStatus;

  /// No description provided for @dosingPumpHeadStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get dosingPumpHeadStatusReady;

  /// No description provided for @dosingPumpHeadDailyTarget.
  ///
  /// In en, this message translates to:
  /// **'Daily target'**
  String get dosingPumpHeadDailyTarget;

  /// No description provided for @dosingPumpHeadTodayDispensed.
  ///
  /// In en, this message translates to:
  /// **'Today dispensed'**
  String get dosingPumpHeadTodayDispensed;

  /// No description provided for @dosingPumpHeadLastDose.
  ///
  /// In en, this message translates to:
  /// **'Last dose'**
  String get dosingPumpHeadLastDose;

  /// No description provided for @dosingPumpHeadFlowRate.
  ///
  /// In en, this message translates to:
  /// **'Calibrated flow'**
  String get dosingPumpHeadFlowRate;

  /// No description provided for @dosingPumpHeadManualDose.
  ///
  /// In en, this message translates to:
  /// **'Manual dose'**
  String get dosingPumpHeadManualDose;

  /// No description provided for @dosingPumpHeadManualDoseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Settings successful.'**
  String get dosingPumpHeadManualDoseSuccess;

  /// No description provided for @dosingPumpHeadTimedDose.
  ///
  /// In en, this message translates to:
  /// **'Schedule timed dose'**
  String get dosingPumpHeadTimedDose;

  /// No description provided for @dosingPumpHeadTimedDoseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Settings successful.'**
  String get dosingPumpHeadTimedDoseSuccess;

  /// No description provided for @dosingPumpHeadCalibrate.
  ///
  /// In en, this message translates to:
  /// **'Calibrate head'**
  String get dosingPumpHeadCalibrate;

  /// No description provided for @dosingPumpHeadPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'No scheduled tasks'**
  String get dosingPumpHeadPlaceholder;

  /// No description provided for @dosingScheduleOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedules'**
  String get dosingScheduleOverviewTitle;

  /// No description provided for @dosingScheduleOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review configured dosing windows.'**
  String get dosingScheduleOverviewSubtitle;

  /// No description provided for @dosingTodayTotalTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s dosing'**
  String get dosingTodayTotalTitle;

  /// No description provided for @dosingTodayTotalTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get dosingTodayTotalTotal;

  /// No description provided for @dosingTodayTotalScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get dosingTodayTotalScheduled;

  /// No description provided for @dosingTodayTotalManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get dosingTodayTotalManual;

  /// No description provided for @dosingTodayTotalEmpty.
  ///
  /// In en, this message translates to:
  /// **'No scheduled tasks'**
  String get dosingTodayTotalEmpty;

  /// No description provided for @dosingScheduleSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule summary'**
  String get dosingScheduleSummaryTitle;

  /// No description provided for @dosingScheduleSummaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No schedule'**
  String get dosingScheduleSummaryEmpty;

  /// No description provided for @dosingScheduleSummaryTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total / day'**
  String get dosingScheduleSummaryTotalLabel;

  /// No description provided for @dosingScheduleSummaryWindowCount.
  ///
  /// In en, this message translates to:
  /// **'{count} windows'**
  String dosingScheduleSummaryWindowCount(int count);

  /// No description provided for @dosingScheduleSummarySlotCount.
  ///
  /// In en, this message translates to:
  /// **'{count} slots'**
  String dosingScheduleSummarySlotCount(int count);

  /// No description provided for @dosingScheduleApplyDailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Apply 24h average schedule'**
  String get dosingScheduleApplyDailyAverage;

  /// No description provided for @dosingScheduleApplyDailyAverageSuccess.
  ///
  /// In en, this message translates to:
  /// **'Settings successful.'**
  String get dosingScheduleApplyDailyAverageSuccess;

  /// No description provided for @dosingScheduleApplyCustomWindow.
  ///
  /// In en, this message translates to:
  /// **'Apply custom window schedule'**
  String get dosingScheduleApplyCustomWindow;

  /// No description provided for @dosingScheduleApplyCustomWindowSuccess.
  ///
  /// In en, this message translates to:
  /// **'Settings successful.'**
  String get dosingScheduleApplyCustomWindowSuccess;

  /// No description provided for @dosingScheduleViewButton.
  ///
  /// In en, this message translates to:
  /// **'View schedules'**
  String get dosingScheduleViewButton;

  /// No description provided for @dosingScheduleEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No scheduled tasks'**
  String get dosingScheduleEmptyTitle;

  /// No description provided for @dosingScheduleEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a schedule with the Reef B app to see it here.'**
  String get dosingScheduleEmptySubtitle;

  /// No description provided for @dosingScheduleTypeDaily.
  ///
  /// In en, this message translates to:
  /// **'24-hour program'**
  String get dosingScheduleTypeDaily;

  /// No description provided for @dosingScheduleTypeSingle.
  ///
  /// In en, this message translates to:
  /// **'Single dose'**
  String get dosingScheduleTypeSingle;

  /// No description provided for @dosingScheduleTypeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom window'**
  String get dosingScheduleTypeCustom;

  /// No description provided for @dosingScheduleRecurrenceDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get dosingScheduleRecurrenceDaily;

  /// No description provided for @dosingScheduleRecurrenceWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get dosingScheduleRecurrenceWeekdays;

  /// No description provided for @dosingScheduleRecurrenceWeekends.
  ///
  /// In en, this message translates to:
  /// **'Weekends'**
  String get dosingScheduleRecurrenceWeekends;

  /// No description provided for @ledDetailUnknownDevice.
  ///
  /// In en, this message translates to:
  /// **'Unnamed device'**
  String get ledDetailUnknownDevice;

  /// No description provided for @ledDetailFavoriteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark as favorite (coming soon)'**
  String get ledDetailFavoriteTooltip;

  /// No description provided for @ledDetailHeaderHint.
  ///
  /// In en, this message translates to:
  /// **'Control spectrum profiles and schedules from your phone.'**
  String get ledDetailHeaderHint;

  /// No description provided for @ledScenesPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Scenes'**
  String get ledScenesPlaceholderTitle;

  /// No description provided for @ledScenesPlaceholderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Swipe through presets from Reef B.'**
  String get ledScenesPlaceholderSubtitle;

  /// No description provided for @ledScheduleSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Lighting schedule'**
  String get ledScheduleSummaryTitle;

  /// No description provided for @ledScheduleSummaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No schedule configured'**
  String get ledScheduleSummaryEmpty;

  /// No description provided for @ledScheduleSummaryWindowLabel.
  ///
  /// In en, this message translates to:
  /// **'Window'**
  String get ledScheduleSummaryWindowLabel;

  /// No description provided for @ledScheduleSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get ledScheduleSummaryLabel;

  /// No description provided for @ledSchedulePlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule preview'**
  String get ledSchedulePlaceholderTitle;

  /// No description provided for @ledSchedulePlaceholderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Planned spectrum envelope for the next 24h.'**
  String get ledSchedulePlaceholderSubtitle;

  /// No description provided for @ledEntryScenes.
  ///
  /// In en, this message translates to:
  /// **'Open Scenes'**
  String get ledEntryScenes;

  /// No description provided for @ledEntrySchedule.
  ///
  /// In en, this message translates to:
  /// **'Open Schedule'**
  String get ledEntrySchedule;

  /// No description provided for @ledScenesListTitle.
  ///
  /// In en, this message translates to:
  /// **'Scenes'**
  String get ledScenesListTitle;

  /// No description provided for @ledScenesListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review presets imported from Reef B.'**
  String get ledScenesListSubtitle;

  /// No description provided for @ledScenesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No scenes available'**
  String get ledScenesEmptyTitle;

  /// No description provided for @ledScenesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sync scenes from the Reef B app to see them here.'**
  String get ledScenesEmptySubtitle;

  /// No description provided for @ledScheduleListTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedules'**
  String get ledScheduleListTitle;

  /// No description provided for @ledScheduleListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review lighting timelines synced from Reef B.'**
  String get ledScheduleListSubtitle;

  /// No description provided for @ledScheduleEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No schedules available'**
  String get ledScheduleEmptyTitle;

  /// No description provided for @ledScheduleEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create schedules in the Reef B app to view them here.'**
  String get ledScheduleEmptySubtitle;

  /// No description provided for @ledScheduleDerivedLabel.
  ///
  /// In en, this message translates to:
  /// **'From LED record'**
  String get ledScheduleDerivedLabel;

  /// No description provided for @ledRecordsTitle.
  ///
  /// In en, this message translates to:
  /// **'LED records'**
  String get ledRecordsTitle;

  /// No description provided for @ledRecordsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage every point in the 24-hour lighting timeline.'**
  String get ledRecordsSubtitle;

  /// No description provided for @ledRecordsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No records available'**
  String get ledRecordsEmptyTitle;

  /// No description provided for @ledRecordsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create records in the Reef B app to see them here.'**
  String get ledRecordsEmptySubtitle;

  /// No description provided for @ledRecordsSelectedTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected time'**
  String get ledRecordsSelectedTimeLabel;

  /// No description provided for @ledRecordsStatusIdle.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ledRecordsStatusIdle;

  /// No description provided for @ledRecordsStatusApplying.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get ledRecordsStatusApplying;

  /// No description provided for @ledRecordsStatusPreview.
  ///
  /// In en, this message translates to:
  /// **'Previewing'**
  String get ledRecordsStatusPreview;

  /// No description provided for @ledRecordsActionPrev.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get ledRecordsActionPrev;

  /// No description provided for @ledRecordsActionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get ledRecordsActionNext;

  /// No description provided for @ledRecordsActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get ledRecordsActionDelete;

  /// No description provided for @ledRecordsActionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get ledRecordsActionClear;

  /// No description provided for @ledRecordsActionPreviewStart.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get ledRecordsActionPreviewStart;

  /// No description provided for @ledRecordsActionPreviewStop.
  ///
  /// In en, this message translates to:
  /// **'Stop preview'**
  String get ledRecordsActionPreviewStop;

  /// No description provided for @ledRecordsClearConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all records?'**
  String get ledRecordsClearConfirmTitle;

  /// No description provided for @ledRecordsClearConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to clear the schedule?'**
  String get ledRecordsClearConfirmMessage;

  /// No description provided for @ledRecordsDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete record?'**
  String get ledRecordsDeleteConfirmTitle;

  /// No description provided for @ledRecordsDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this time point?'**
  String get ledRecordsDeleteConfirmMessage;

  /// No description provided for @ledMoveMasterDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Master Setting'**
  String get ledMoveMasterDialogTitle;

  /// No description provided for @ledMoveMasterDialogContent.
  ///
  /// In en, this message translates to:
  /// **'To move this device to another tank, please first modify the master-slave settings and set other slave lights as the master light.'**
  String get ledMoveMasterDialogContent;

  /// No description provided for @ledSceneDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete the scene?'**
  String ledSceneDeleteConfirmMessage(String name);

  /// No description provided for @ledRecordsSnackDeleted.
  ///
  /// In en, this message translates to:
  /// **'Successfully deleted time point.'**
  String get ledRecordsSnackDeleted;

  /// No description provided for @ledRecordsSnackDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete time point.'**
  String get ledRecordsSnackDeleteFailed;

  /// No description provided for @ledRecordsSnackCleared.
  ///
  /// In en, this message translates to:
  /// **'Records cleared.'**
  String get ledRecordsSnackCleared;

  /// No description provided for @ledRecordsSnackClearFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t clear records.'**
  String get ledRecordsSnackClearFailed;

  /// No description provided for @ledRecordsSnackMissingSelection.
  ///
  /// In en, this message translates to:
  /// **'Select a record first.'**
  String get ledRecordsSnackMissingSelection;

  /// No description provided for @ledRecordsSnackPreviewStarted.
  ///
  /// In en, this message translates to:
  /// **'One-minute quick preview started.'**
  String get ledRecordsSnackPreviewStarted;

  /// No description provided for @ledRecordsSnackPreviewStopped.
  ///
  /// In en, this message translates to:
  /// **'One-minute quick preview ended.'**
  String get ledRecordsSnackPreviewStopped;

  /// No description provided for @ledRecordsSnackRecordsFull.
  ///
  /// In en, this message translates to:
  /// **'Maximum 24 time points can be set.'**
  String get ledRecordsSnackRecordsFull;

  /// No description provided for @ledRecordsSnackTimeExists.
  ///
  /// In en, this message translates to:
  /// **'This time period has already been set.'**
  String get ledRecordsSnackTimeExists;

  /// No description provided for @ledRecordsSnackTimeError.
  ///
  /// In en, this message translates to:
  /// **'Time points must be at least 10 minutes apart.'**
  String get ledRecordsSnackTimeError;

  /// No description provided for @ledScheduleTypeDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily program'**
  String get ledScheduleTypeDaily;

  /// No description provided for @ledScheduleTypeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom window'**
  String get ledScheduleTypeCustom;

  /// No description provided for @ledScheduleTypeScene.
  ///
  /// In en, this message translates to:
  /// **'Scene-based'**
  String get ledScheduleTypeScene;

  /// No description provided for @ledScheduleRecurrenceDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get ledScheduleRecurrenceDaily;

  /// No description provided for @ledScheduleRecurrenceWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get ledScheduleRecurrenceWeekdays;

  /// No description provided for @ledScheduleRecurrenceWeekends.
  ///
  /// In en, this message translates to:
  /// **'Weekends'**
  String get ledScheduleRecurrenceWeekends;

  /// No description provided for @ledScheduleSceneSummary.
  ///
  /// In en, this message translates to:
  /// **'Scene: {scene}'**
  String ledScheduleSceneSummary(String scene);

  /// No description provided for @dosingCalibrationHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Calibration history'**
  String get dosingCalibrationHistoryTitle;

  /// No description provided for @dosingCalibrationHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Latest calibrations captured per speed.'**
  String get dosingCalibrationHistorySubtitle;

  /// No description provided for @dosingCalibrationHistoryViewButton.
  ///
  /// In en, this message translates to:
  /// **'View calibration history'**
  String get dosingCalibrationHistoryViewButton;

  /// No description provided for @dosingCalibrationHistoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No calibrations yet'**
  String get dosingCalibrationHistoryEmptyTitle;

  /// No description provided for @dosingCalibrationHistoryEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Run a calibration from the Reef B app to see it here.'**
  String get dosingCalibrationHistoryEmptySubtitle;

  /// No description provided for @dosingCalibrationRecordNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get dosingCalibrationRecordNoteLabel;

  /// No description provided for @dosingCalibrationRecordSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed: {speed}'**
  String dosingCalibrationRecordSpeed(String speed);

  /// No description provided for @dosingCalibrationRecordFlow.
  ///
  /// In en, this message translates to:
  /// **'{flow} ml/min'**
  String dosingCalibrationRecordFlow(String flow);

  /// No description provided for @dosingPumpHeadSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pump head settings'**
  String get dosingPumpHeadSettingsTitle;

  /// No description provided for @dosingPumpHeadSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rename the head or adjust execution delay.'**
  String get dosingPumpHeadSettingsSubtitle;

  /// No description provided for @dosingPumpHeadSettingsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Pump head name'**
  String get dosingPumpHeadSettingsNameLabel;

  /// No description provided for @dosingPumpHeadSettingsNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a custom label'**
  String get dosingPumpHeadSettingsNameHint;

  /// No description provided for @dosingPumpHeadSettingsNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty.'**
  String get dosingPumpHeadSettingsNameEmpty;

  /// No description provided for @dosingPumpHeadSettingsTankLabel.
  ///
  /// In en, this message translates to:
  /// **'Tank / additive'**
  String get dosingPumpHeadSettingsTankLabel;

  /// No description provided for @dosingPumpHeadSettingsTankPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Link additives from the Reef B app.'**
  String get dosingPumpHeadSettingsTankPlaceholder;

  /// No description provided for @dosingPumpHeadSettingsDelayLabel.
  ///
  /// In en, this message translates to:
  /// **'Dose delay'**
  String get dosingPumpHeadSettingsDelayLabel;

  /// No description provided for @dosingPumpHeadSettingsDelaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Applies a delay before the head runs.'**
  String get dosingPumpHeadSettingsDelaySubtitle;

  /// No description provided for @dosingPumpHeadSettingsUnsavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get dosingPumpHeadSettingsUnsavedTitle;

  /// No description provided for @dosingPumpHeadSettingsUnsavedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes.'**
  String get dosingPumpHeadSettingsUnsavedMessage;

  /// No description provided for @dosingPumpHeadSettingsUnsavedDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get dosingPumpHeadSettingsUnsavedDiscard;

  /// No description provided for @dosingPumpHeadSettingsUnsavedStay.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dosingPumpHeadSettingsUnsavedStay;

  /// No description provided for @dosingPumpHeadSettingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get dosingPumpHeadSettingsSave;

  /// No description provided for @dosingPumpHeadSettingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dosingPumpHeadSettingsCancel;

  /// No description provided for @dosingPumpHeadSettingsDelayOption.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds'**
  String dosingPumpHeadSettingsDelayOption(int seconds);

  /// No description provided for @dosingScheduleStatusEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get dosingScheduleStatusEnabled;

  /// No description provided for @dosingScheduleStatusDisabled.
  ///
  /// In en, this message translates to:
  /// **'The schedule is paused.'**
  String get dosingScheduleStatusDisabled;

  /// No description provided for @dosingScheduleDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this schedule?'**
  String get dosingScheduleDeleteConfirmMessage;

  /// No description provided for @dosingScheduleDeleted.
  ///
  /// In en, this message translates to:
  /// **'Schedule deleted.'**
  String get dosingScheduleDeleted;

  /// Label shown next to an LED scene when it is enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get ledSceneStatusEnabled;

  /// Label shown next to an LED scene when it is disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get ledSceneStatusDisabled;

  /// No description provided for @ledSceneStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get ledSceneStatusActive;

  /// No description provided for @ledScenesSnackApplied.
  ///
  /// In en, this message translates to:
  /// **'Scene applied.'**
  String get ledScenesSnackApplied;

  /// Label shown when an LED lighting schedule is enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get ledScheduleStatusEnabled;

  /// Label shown when an LED lighting schedule is disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get ledScheduleStatusDisabled;

  /// No description provided for @ledScheduleStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get ledScheduleStatusActive;

  /// No description provided for @ledScheduleSnackApplied.
  ///
  /// In en, this message translates to:
  /// **'Schedule applied.'**
  String get ledScheduleSnackApplied;

  /// No description provided for @ledRuntimeStatus.
  ///
  /// In en, this message translates to:
  /// **'Runtime status'**
  String get ledRuntimeStatus;

  /// No description provided for @ledRuntimeIdle.
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get ledRuntimeIdle;

  /// No description provided for @ledRuntimeApplying.
  ///
  /// In en, this message translates to:
  /// **'Applying'**
  String get ledRuntimeApplying;

  /// No description provided for @ledRuntimePreview.
  ///
  /// In en, this message translates to:
  /// **'Previewing'**
  String get ledRuntimePreview;

  /// No description provided for @ledRuntimeScheduleActive.
  ///
  /// In en, this message translates to:
  /// **'Schedule active'**
  String get ledRuntimeScheduleActive;

  /// No description provided for @ledSceneCurrentlyRunning.
  ///
  /// In en, this message translates to:
  /// **'Currently running'**
  String get ledSceneCurrentlyRunning;

  /// No description provided for @ledScenePreset.
  ///
  /// In en, this message translates to:
  /// **'Preset scene'**
  String get ledScenePreset;

  /// No description provided for @ledSceneCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom scene'**
  String get ledSceneCustom;

  /// No description provided for @ledSceneChannelCount.
  ///
  /// In en, this message translates to:
  /// **'{count} channels'**
  String ledSceneChannelCount(int count);

  /// No description provided for @ledScheduleDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily schedule'**
  String get ledScheduleDaily;

  /// No description provided for @ledScheduleWindow.
  ///
  /// In en, this message translates to:
  /// **'Time window'**
  String get ledScheduleWindow;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// Delete action button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// Skip step button
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// No description provided for @actionRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get actionRefresh;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// Next step button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// Device name label
  ///
  /// In en, this message translates to:
  /// **'Device Name'**
  String get deviceName;

  /// No description provided for @deviceNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter device name'**
  String get deviceNameHint;

  /// No description provided for @deviceNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Device name cannot be empty'**
  String get deviceNameEmpty;

  /// No description provided for @deviceId.
  ///
  /// In en, this message translates to:
  /// **'Device ID'**
  String get deviceId;

  /// No description provided for @deviceInfo.
  ///
  /// In en, this message translates to:
  /// **'Device Info'**
  String get deviceInfo;

  /// No description provided for @deviceSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Settings'**
  String get deviceSettingsTitle;

  /// No description provided for @deviceSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get deviceSettingsSaved;

  /// No description provided for @deviceSettingsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this device?'**
  String get deviceSettingsDeleteConfirm;

  /// No description provided for @deviceSettingsDeleteDevice.
  ///
  /// In en, this message translates to:
  /// **'Delete Device'**
  String get deviceSettingsDeleteDevice;

  /// No description provided for @deviceActionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get deviceActionEdit;

  /// No description provided for @deviceActionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Device'**
  String get deviceActionAdd;

  /// No description provided for @deviceState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get deviceState;

  /// No description provided for @ledSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'LED Settings'**
  String get ledSettingTitle;

  /// No description provided for @ledRecordSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'LED Record Settings'**
  String get ledRecordSettingTitle;

  /// No description provided for @ledRecordTimeSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'LED Record Time Settings'**
  String get ledRecordTimeSettingTitle;

  /// No description provided for @ledSceneAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Scene'**
  String get ledSceneAddTitle;

  /// No description provided for @ledSceneEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Scene'**
  String get ledSceneEditTitle;

  /// No description provided for @ledSceneDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Scene'**
  String get ledSceneDeleteTitle;

  /// No description provided for @ledMasterSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Master-Slave Pairing'**
  String get ledMasterSettingTitle;

  /// No description provided for @ledSetMaster.
  ///
  /// In en, this message translates to:
  /// **'Set as Master Light'**
  String get ledSetMaster;

  /// No description provided for @ledMoveGroup.
  ///
  /// In en, this message translates to:
  /// **'Move Group'**
  String get ledMoveGroup;

  /// No description provided for @ledMasterSettingMenuPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Requires device and sink configuration.'**
  String get ledMasterSettingMenuPlaceholder;

  /// No description provided for @ledRecordTimeSettingTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get ledRecordTimeSettingTimeLabel;

  /// No description provided for @ledRecordTimeSettingSpectrumLabel.
  ///
  /// In en, this message translates to:
  /// **'Spectrum'**
  String get ledRecordTimeSettingSpectrumLabel;

  /// No description provided for @ledRecordTimeSettingChannelsLabel.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get ledRecordTimeSettingChannelsLabel;

  /// No description provided for @ledRecordTimeSettingErrorTime.
  ///
  /// In en, this message translates to:
  /// **'Invalid time'**
  String get ledRecordTimeSettingErrorTime;

  /// No description provided for @ledRecordTimeSettingErrorTimeExists.
  ///
  /// In en, this message translates to:
  /// **'Time already exists'**
  String get ledRecordTimeSettingErrorTimeExists;

  /// No description provided for @ledRecordTimeSettingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Record saved'**
  String get ledRecordTimeSettingSuccess;

  /// No description provided for @ledSceneNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Scene Name'**
  String get ledSceneNameLabel;

  /// No description provided for @ledSceneNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter scene name'**
  String get ledSceneNameHint;

  /// No description provided for @ledSceneIcon.
  ///
  /// In en, this message translates to:
  /// **'Scene Icon'**
  String get ledSceneIcon;

  /// No description provided for @lightUv.
  ///
  /// In en, this message translates to:
  /// **'UV Light'**
  String get lightUv;

  /// No description provided for @lightPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple Light'**
  String get lightPurple;

  /// No description provided for @lightBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue Light'**
  String get lightBlue;

  /// No description provided for @lightRoyalBlue.
  ///
  /// In en, this message translates to:
  /// **'Royal Blue Light'**
  String get lightRoyalBlue;

  /// No description provided for @lightGreen.
  ///
  /// In en, this message translates to:
  /// **'Green Light'**
  String get lightGreen;

  /// No description provided for @lightRed.
  ///
  /// In en, this message translates to:
  /// **'Red Light'**
  String get lightRed;

  /// No description provided for @lightColdWhite.
  ///
  /// In en, this message translates to:
  /// **'Cool White Light'**
  String get lightColdWhite;

  /// No description provided for @lightWarmWhite.
  ///
  /// In en, this message translates to:
  /// **'Warm White Light'**
  String get lightWarmWhite;

  /// No description provided for @lightMoon.
  ///
  /// In en, this message translates to:
  /// **'Moonlight'**
  String get lightMoon;

  /// No description provided for @ledSceneAddSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully added scene.'**
  String get ledSceneAddSuccess;

  /// No description provided for @toastNameIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty.'**
  String get toastNameIsEmpty;

  /// No description provided for @toastSettingSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Settings successful.'**
  String get toastSettingSuccessful;

  /// No description provided for @toastSettingFailed.
  ///
  /// In en, this message translates to:
  /// **'Settings failed.'**
  String get toastSettingFailed;

  /// No description provided for @toastSetTimeError.
  ///
  /// In en, this message translates to:
  /// **'Time points must be at least 10 minutes apart.'**
  String get toastSetTimeError;

  /// No description provided for @toastSetTimeIsExist.
  ///
  /// In en, this message translates to:
  /// **'This time period has already been set.'**
  String get toastSetTimeIsExist;

  /// No description provided for @hintSelectTime.
  ///
  /// In en, this message translates to:
  /// **'Please select a time.'**
  String get hintSelectTime;

  /// No description provided for @toastSceneNameIsExist.
  ///
  /// In en, this message translates to:
  /// **'Scene name already exists.'**
  String get toastSceneNameIsExist;

  /// No description provided for @ledSceneNameIsExist.
  ///
  /// In en, this message translates to:
  /// **'Scene name already exists.'**
  String get ledSceneNameIsExist;

  /// No description provided for @ledSceneDeleteDescription.
  ///
  /// In en, this message translates to:
  /// **'Select scenes to delete'**
  String get ledSceneDeleteDescription;

  /// No description provided for @ledSceneDeleteEmpty.
  ///
  /// In en, this message translates to:
  /// **'No scenes to delete'**
  String get ledSceneDeleteEmpty;

  /// No description provided for @ledSceneDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Scene?'**
  String get ledSceneDeleteConfirmTitle;

  /// No description provided for @ledSceneDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Scene \"{name}\" deleted'**
  String ledSceneDeleteSuccess(String name);

  /// No description provided for @ledSceneDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete scene.'**
  String get ledSceneDeleteError;

  /// No description provided for @toastDeleteNowScene.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete the currently in-use scene.'**
  String get toastDeleteNowScene;

  /// No description provided for @ledSceneDeleteLocalScenesTitle.
  ///
  /// In en, this message translates to:
  /// **'Local Scenes'**
  String get ledSceneDeleteLocalScenesTitle;

  /// No description provided for @ledSceneDeleteDeviceScenesTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Scenes (Read-only)'**
  String get ledSceneDeleteDeviceScenesTitle;

  /// No description provided for @ledSceneDeleteCannotDeleteDeviceScenes.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete device scenes'**
  String get ledSceneDeleteCannotDeleteDeviceScenes;

  /// No description provided for @ledSceneIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Scene ID: {id}'**
  String ledSceneIdLabel(String id);

  /// No description provided for @ledSceneLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum 5 custom scenes can be set.'**
  String get ledSceneLimitReached;

  /// No description provided for @ledMasterSettingGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get ledMasterSettingGroup;

  /// No description provided for @ledMasterSettingMaster.
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get ledMasterSettingMaster;

  /// No description provided for @ledMasterSettingSlave.
  ///
  /// In en, this message translates to:
  /// **'Slave'**
  String get ledMasterSettingSlave;

  /// No description provided for @ledMasterSettingSetMaster.
  ///
  /// In en, this message translates to:
  /// **'Set as Master'**
  String get ledMasterSettingSetMaster;

  /// No description provided for @ledMasterSettingMoveGroup.
  ///
  /// In en, this message translates to:
  /// **'Move Group'**
  String get ledMasterSettingMoveGroup;

  /// No description provided for @ledMasterSettingSetMasterSuccess.
  ///
  /// In en, this message translates to:
  /// **'Master set successfully'**
  String get ledMasterSettingSetMasterSuccess;

  /// No description provided for @ledMasterSettingSelectGroup.
  ///
  /// In en, this message translates to:
  /// **'Select Group'**
  String get ledMasterSettingSelectGroup;

  /// No description provided for @ledMasterSettingGroupFull.
  ///
  /// In en, this message translates to:
  /// **'Group is full'**
  String get ledMasterSettingGroupFull;

  /// No description provided for @ledMasterSettingMoveGroupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Group moved successfully'**
  String get ledMasterSettingMoveGroupSuccess;

  /// No description provided for @ledMasterSettingMoveGroupFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to move group'**
  String get ledMasterSettingMoveGroupFailed;

  /// No description provided for @ledRecordSettingInitStrength.
  ///
  /// In en, this message translates to:
  /// **'Initial Strength'**
  String get ledRecordSettingInitStrength;

  /// No description provided for @ledRecordSettingSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get ledRecordSettingSunrise;

  /// No description provided for @ledRecordSettingSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get ledRecordSettingSunset;

  /// No description provided for @ledRecordSettingSlowStart.
  ///
  /// In en, this message translates to:
  /// **'Slow Start'**
  String get ledRecordSettingSlowStart;

  /// No description provided for @ledRecordSettingMoonlight.
  ///
  /// In en, this message translates to:
  /// **'Moonlight'**
  String get ledRecordSettingMoonlight;

  /// No description provided for @ledRecordSettingErrorSunTime.
  ///
  /// In en, this message translates to:
  /// **'Sunrise and sunset time settings are incorrect.'**
  String get ledRecordSettingErrorSunTime;

  /// No description provided for @ledRecordSettingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get ledRecordSettingSuccess;

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'minute'**
  String get minute;

  /// No description provided for @ledScenesActionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get ledScenesActionEdit;

  /// No description provided for @ledDynamicScene.
  ///
  /// In en, this message translates to:
  /// **'Dynamic Scene'**
  String get ledDynamicScene;

  /// No description provided for @ledStaticScene.
  ///
  /// In en, this message translates to:
  /// **'Static Scene'**
  String get ledStaticScene;

  /// No description provided for @ledScenesActionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Scene'**
  String get ledScenesActionAdd;

  /// No description provided for @ledScenesActionUnfavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove Favorite'**
  String get ledScenesActionUnfavorite;

  /// No description provided for @ledScenesActionFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add Favorite'**
  String get ledScenesActionFavorite;

  /// No description provided for @deviceActionFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get deviceActionFavorite;

  /// No description provided for @deviceActionUnfavorite.
  ///
  /// In en, this message translates to:
  /// **'Unfavorite'**
  String get deviceActionUnfavorite;

  /// No description provided for @deviceFavorited.
  ///
  /// In en, this message translates to:
  /// **'Device favorited'**
  String get deviceFavorited;

  /// No description provided for @deviceUnfavorited.
  ///
  /// In en, this message translates to:
  /// **'Device unfavorited'**
  String get deviceUnfavorited;

  /// No description provided for @ledOrientationPortrait.
  ///
  /// In en, this message translates to:
  /// **'Portrait'**
  String get ledOrientationPortrait;

  /// No description provided for @ledOrientationLandscape.
  ///
  /// In en, this message translates to:
  /// **'Landscape'**
  String get ledOrientationLandscape;

  /// No description provided for @ledFavoriteScenesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorite Scenes'**
  String get ledFavoriteScenesTitle;

  /// No description provided for @ledFavoriteScenesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your favorite scenes'**
  String get ledFavoriteScenesSubtitle;

  /// No description provided for @ledContinueRecord.
  ///
  /// In en, this message translates to:
  /// **'Resume execution.'**
  String get ledContinueRecord;

  /// No description provided for @actionPlay.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get actionPlay;

  /// No description provided for @ledResetDevice.
  ///
  /// In en, this message translates to:
  /// **'Reset Device'**
  String get ledResetDevice;

  /// No description provided for @sinkTypeDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get sinkTypeDefault;

  /// Tank/sink position setting
  ///
  /// In en, this message translates to:
  /// **'Tank Location'**
  String get sinkPosition;

  /// No description provided for @sinkPositionTitle.
  ///
  /// In en, this message translates to:
  /// **'Sink Position'**
  String get sinkPositionTitle;

  /// No description provided for @sinkPositionNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not Set'**
  String get sinkPositionNotSet;

  /// No description provided for @errorLedMasterCannotMove.
  ///
  /// In en, this message translates to:
  /// **'To move this device to another tank, please first modify the master-slave settings and set other slave lights as the master light.'**
  String get errorLedMasterCannotMove;

  /// No description provided for @masterSetting.
  ///
  /// In en, this message translates to:
  /// **'Master Setting'**
  String get masterSetting;

  /// No description provided for @sinkPositionSet.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get sinkPositionSet;

  /// No description provided for @sinkAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Sink'**
  String get sinkAddTitle;

  /// No description provided for @sinkNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Sink Name'**
  String get sinkNameLabel;

  /// No description provided for @sinkNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter sink name'**
  String get sinkNameHint;

  /// No description provided for @sinkAddSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sink added'**
  String get sinkAddSuccess;

  /// No description provided for @sinkNameExists.
  ///
  /// In en, this message translates to:
  /// **'Sink name already exists'**
  String get sinkNameExists;

  /// No description provided for @sinkManagerTitle.
  ///
  /// In en, this message translates to:
  /// **'Sink Manager'**
  String get sinkManagerTitle;

  /// No description provided for @sinkEmptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'No Sinks'**
  String get sinkEmptyStateTitle;

  /// No description provided for @sinkEmptyStateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a sink to get started'**
  String get sinkEmptyStateSubtitle;

  /// No description provided for @sinkEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Sink'**
  String get sinkEditTitle;

  /// No description provided for @sinkDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Sink'**
  String get sinkDeleteTitle;

  /// No description provided for @sinkDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this sink?'**
  String get sinkDeleteMessage;

  /// No description provided for @sinkEditSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sink updated.'**
  String get sinkEditSuccess;

  /// No description provided for @sinkDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sink deleted.'**
  String get sinkDeleteSuccess;

  /// No description provided for @sinkDeviceCount.
  ///
  /// In en, this message translates to:
  /// **'{count} devices'**
  String sinkDeviceCount(int count);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @warningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get warningTitle;

  /// No description provided for @warningClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get warningClearAll;

  /// No description provided for @warningClearAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear All Warnings?'**
  String get warningClearAllTitle;

  /// No description provided for @warningClearAllContent.
  ///
  /// In en, this message translates to:
  /// **'This will clear all warnings'**
  String get warningClearAllContent;

  /// No description provided for @warningClearAllSuccess.
  ///
  /// In en, this message translates to:
  /// **'All warnings cleared'**
  String get warningClearAllSuccess;

  /// No description provided for @warningId.
  ///
  /// In en, this message translates to:
  /// **'Warning ID: {id}'**
  String warningId(int id);

  /// No description provided for @warningEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Warnings'**
  String get warningEmptyTitle;

  /// No description provided for @warningEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'All clear!'**
  String get warningEmptySubtitle;

  /// No description provided for @addDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Device'**
  String get addDeviceTitle;

  /// No description provided for @addDeviceSuccess.
  ///
  /// In en, this message translates to:
  /// **'Device added'**
  String get addDeviceSuccess;

  /// No description provided for @addDeviceFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add device'**
  String get addDeviceFailed;

  /// No description provided for @dosingScheduleEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Schedule'**
  String get dosingScheduleEditTitle;

  /// No description provided for @dosingScheduleTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Schedule Type'**
  String get dosingScheduleTypeLabel;

  /// No description provided for @dosingScheduleTypeNone.
  ///
  /// In en, this message translates to:
  /// **'No Schedule'**
  String get dosingScheduleTypeNone;

  /// No description provided for @dosingScheduleType24h.
  ///
  /// In en, this message translates to:
  /// **'24-Hour Average'**
  String get dosingScheduleType24h;

  /// No description provided for @dosingScheduleEditTimeRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time Range'**
  String get dosingScheduleEditTimeRangeLabel;

  /// No description provided for @dosingScheduleEditTimePointLabel.
  ///
  /// In en, this message translates to:
  /// **'Time Point'**
  String get dosingScheduleEditTimePointLabel;

  /// No description provided for @dosingScheduleEditSelectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get dosingScheduleEditSelectDateRange;

  /// No description provided for @dosingScheduleEditSelectDateTime.
  ///
  /// In en, this message translates to:
  /// **'Select Date & Time'**
  String get dosingScheduleEditSelectDateTime;

  /// No description provided for @dosingScheduleEditCustomDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom Details'**
  String get dosingScheduleEditCustomDetailsLabel;

  /// No description provided for @dosingScheduleEditNoTimeSlots.
  ///
  /// In en, this message translates to:
  /// **'No time slots'**
  String get dosingScheduleEditNoTimeSlots;

  /// No description provided for @dosingScheduleEditRotatingSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Rotating Speed'**
  String get dosingScheduleEditRotatingSpeedLabel;

  /// No description provided for @dosingScheduleEditSpeedLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get dosingScheduleEditSpeedLow;

  /// No description provided for @dosingScheduleEditSpeedMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get dosingScheduleEditSpeedMedium;

  /// No description provided for @dosingScheduleEditSpeedHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get dosingScheduleEditSpeedHigh;

  /// No description provided for @dosingScheduleEditErrorVolumeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Volume cannot be empty'**
  String get dosingScheduleEditErrorVolumeEmpty;

  /// No description provided for @dosingScheduleEditErrorTimeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Time cannot be empty'**
  String get dosingScheduleEditErrorTimeEmpty;

  /// No description provided for @dosingScheduleEditErrorVolumeTooLittleNew.
  ///
  /// In en, this message translates to:
  /// **'Volume too little'**
  String get dosingScheduleEditErrorVolumeTooLittleNew;

  /// No description provided for @dosingScheduleEditErrorVolumeTooLittleOld.
  ///
  /// In en, this message translates to:
  /// **'Volume too little (old)'**
  String get dosingScheduleEditErrorVolumeTooLittleOld;

  /// No description provided for @dosingScheduleEditErrorVolumeTooMuch.
  ///
  /// In en, this message translates to:
  /// **'Volume too much'**
  String get dosingScheduleEditErrorVolumeTooMuch;

  /// No description provided for @dosingScheduleEditErrorVolumeOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Volume exceeds maximum limit'**
  String get dosingScheduleEditErrorVolumeOutOfRange;

  /// No description provided for @dosingScheduleEditErrorDetailsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Time slots are required'**
  String get dosingScheduleEditErrorDetailsEmpty;

  /// No description provided for @dosingScheduleEditErrorTimeExists.
  ///
  /// In en, this message translates to:
  /// **'Time already exists'**
  String get dosingScheduleEditErrorTimeExists;

  /// No description provided for @dosingScheduleEditTimeSlotTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Time Slot'**
  String get dosingScheduleEditTimeSlotTitle;

  /// No description provided for @dosingScheduleEditSelectStartTime.
  ///
  /// In en, this message translates to:
  /// **'Select Start Time'**
  String get dosingScheduleEditSelectStartTime;

  /// No description provided for @dosingScheduleEditSelectEndTime.
  ///
  /// In en, this message translates to:
  /// **'Select End Time'**
  String get dosingScheduleEditSelectEndTime;

  /// No description provided for @dosingScheduleEditDropTimesLabel.
  ///
  /// In en, this message translates to:
  /// **'Drop Times'**
  String get dosingScheduleEditDropTimesLabel;

  /// No description provided for @dosingCalibrationAdjustListTitle.
  ///
  /// In en, this message translates to:
  /// **'Adjustment List'**
  String get dosingCalibrationAdjustListTitle;

  /// No description provided for @dosingResetDevice.
  ///
  /// In en, this message translates to:
  /// **'Reset Device'**
  String get dosingResetDevice;

  /// No description provided for @dosingResetDeviceSuccess.
  ///
  /// In en, this message translates to:
  /// **'Device reset successfully'**
  String get dosingResetDeviceSuccess;

  /// No description provided for @dosingResetDeviceFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset device'**
  String get dosingResetDeviceFailed;

  /// No description provided for @dosingResetDeviceConfirm.
  ///
  /// In en, this message translates to:
  /// **'This device will become unassigned and clear all current pump settings and calibration records.'**
  String get dosingResetDeviceConfirm;

  /// No description provided for @dosingDeleteDeviceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this dosing pump?'**
  String get dosingDeleteDeviceConfirm;

  /// No description provided for @dosingDeleteDeviceSuccess.
  ///
  /// In en, this message translates to:
  /// **'Device deleted successfully'**
  String get dosingDeleteDeviceSuccess;

  /// No description provided for @dosingTodayDropOutOfRangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Max Dosing Volume'**
  String get dosingTodayDropOutOfRangeTitle;

  /// No description provided for @dosingTodayDropOutOfRangeContent.
  ///
  /// In en, this message translates to:
  /// **'Today\'s dosing volume has reached the maximum daily dosing volume.'**
  String get dosingTodayDropOutOfRangeContent;

  /// No description provided for @dosingDropHeadIsDropping.
  ///
  /// In en, this message translates to:
  /// **'This pump head is currently dosing, please try again later.'**
  String get dosingDropHeadIsDropping;

  /// No description provided for @dosingDeleteDeviceFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete device'**
  String get dosingDeleteDeviceFailed;

  /// No description provided for @actionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get actionReset;

  /// No description provided for @dosingNoPumpHeads.
  ///
  /// In en, this message translates to:
  /// **'No pump heads'**
  String get dosingNoPumpHeads;

  /// No description provided for @dosingHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get dosingHistorySubtitle;

  /// No description provided for @dosingAdjustListTitle.
  ///
  /// In en, this message translates to:
  /// **'Calibration Log'**
  String get dosingAdjustListTitle;

  /// No description provided for @dosingAdjustListStartAdjust.
  ///
  /// In en, this message translates to:
  /// **'Start Adjustment'**
  String get dosingAdjustListStartAdjust;

  /// No description provided for @dosingRotatingSpeedLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get dosingRotatingSpeedLow;

  /// No description provided for @dosingRotatingSpeedMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get dosingRotatingSpeedMedium;

  /// No description provided for @dosingRotatingSpeedHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get dosingRotatingSpeedHigh;

  /// No description provided for @dosingAdjustListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Adjustments'**
  String get dosingAdjustListEmptyTitle;

  /// No description provided for @dosingAdjustListEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'No adjustment records yet'**
  String get dosingAdjustListEmptySubtitle;

  /// No description provided for @dropSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Drop Settings'**
  String get dropSettingTitle;

  /// Delay time setting
  ///
  /// In en, this message translates to:
  /// **'Delay Time'**
  String get delayTime;

  /// No description provided for @delayTimeRequiresConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection required for delay time'**
  String get delayTimeRequiresConnection;

  /// No description provided for @delay15Sec.
  ///
  /// In en, this message translates to:
  /// **'15 sec'**
  String get delay15Sec;

  /// No description provided for @delay30Sec.
  ///
  /// In en, this message translates to:
  /// **'30 sec'**
  String get delay30Sec;

  /// No description provided for @delay1Min.
  ///
  /// In en, this message translates to:
  /// **'1 min'**
  String get delay1Min;

  /// No description provided for @delay2Min.
  ///
  /// In en, this message translates to:
  /// **'2 min'**
  String get delay2Min;

  /// No description provided for @delay3Min.
  ///
  /// In en, this message translates to:
  /// **'3 min'**
  String get delay3Min;

  /// No description provided for @delay4Min.
  ///
  /// In en, this message translates to:
  /// **'4 min'**
  String get delay4Min;

  /// No description provided for @delay5Min.
  ///
  /// In en, this message translates to:
  /// **'5 min'**
  String get delay5Min;

  /// No description provided for @delaySecondsFallback.
  ///
  /// In en, this message translates to:
  /// **'{seconds} sec'**
  String delaySecondsFallback(int seconds);

  /// No description provided for @sinkPositionFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get sinkPositionFeatureComingSoon;

  /// No description provided for @dropTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Drop Types'**
  String get dropTypeTitle;

  /// No description provided for @dropTypeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage drop types'**
  String get dropTypeSubtitle;

  /// No description provided for @dropTypeNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get dropTypeNo;

  /// No description provided for @dropTypeAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Drop Type'**
  String get dropTypeAddTitle;

  /// No description provided for @dropTypeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Drop Type Name'**
  String get dropTypeNameLabel;

  /// No description provided for @dropTypeNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter drop type name'**
  String get dropTypeNameHint;

  /// No description provided for @dropTypeAddSuccess.
  ///
  /// In en, this message translates to:
  /// **'Drop type added'**
  String get dropTypeAddSuccess;

  /// No description provided for @dropTypeNameExists.
  ///
  /// In en, this message translates to:
  /// **'Drop type name already exists'**
  String get dropTypeNameExists;

  /// No description provided for @dropTypeEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Drop Type'**
  String get dropTypeEditTitle;

  /// No description provided for @dropTypeEditSuccess.
  ///
  /// In en, this message translates to:
  /// **'Drop type updated'**
  String get dropTypeEditSuccess;

  /// No description provided for @dropTypeDeleteUsedTitle.
  ///
  /// In en, this message translates to:
  /// **'Drop Type in Use'**
  String get dropTypeDeleteUsedTitle;

  /// No description provided for @dropTypeDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Drop Type'**
  String get dropTypeDeleteTitle;

  /// No description provided for @dropTypeDeleteUsedContent.
  ///
  /// In en, this message translates to:
  /// **'This drop type is in use and cannot be deleted'**
  String get dropTypeDeleteUsedContent;

  /// No description provided for @dropTypeDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this drop type?'**
  String get dropTypeDeleteContent;

  /// No description provided for @dropTypeDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Drop type deleted'**
  String get dropTypeDeleteSuccess;

  /// No description provided for @dropTypeDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete drop type'**
  String get dropTypeDeleteFailed;

  /// No description provided for @weekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySunday;

  /// No description provided for @weekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaySaturday;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @led.
  ///
  /// In en, this message translates to:
  /// **'LED'**
  String get led;

  /// No description provided for @drop.
  ///
  /// In en, this message translates to:
  /// **'Dosing Pump'**
  String get drop;

  /// No description provided for @masterSlave.
  ///
  /// In en, this message translates to:
  /// **'Master/Slave'**
  String get masterSlave;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time Point'**
  String get time;

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get record;

  /// No description provided for @ledScene.
  ///
  /// In en, this message translates to:
  /// **'Scene'**
  String get ledScene;

  /// No description provided for @unassignedDevice.
  ///
  /// In en, this message translates to:
  /// **'Unallocated Devices'**
  String get unassignedDevice;

  /// No description provided for @ledSceneNoSetting.
  ///
  /// In en, this message translates to:
  /// **'No Setting'**
  String get ledSceneNoSetting;

  /// No description provided for @dosingAdjustListDate.
  ///
  /// In en, this message translates to:
  /// **'Calibration Date'**
  String get dosingAdjustListDate;

  /// No description provided for @dosingAdjustListVolume.
  ///
  /// In en, this message translates to:
  /// **'Measured Volume'**
  String get dosingAdjustListVolume;

  /// No description provided for @dosingAdjustTitle.
  ///
  /// In en, this message translates to:
  /// **'Calibration'**
  String get dosingAdjustTitle;

  /// No description provided for @dosingAdjustDescription.
  ///
  /// In en, this message translates to:
  /// **'Calibration Instructions'**
  String get dosingAdjustDescription;

  /// No description provided for @dosingAdjustStep.
  ///
  /// In en, this message translates to:
  /// **'1. Prepare the included measuring cup and some tubes\n2. Start manual operation to fill the tubes with liquid\n3. Select the speed for calibration'**
  String get dosingAdjustStep;

  /// No description provided for @dosingRotatingSpeedTitle.
  ///
  /// In en, this message translates to:
  /// **'Rotating Speed'**
  String get dosingRotatingSpeedTitle;

  /// No description provided for @dosingDropVolume.
  ///
  /// In en, this message translates to:
  /// **'Drop Volume'**
  String get dosingDropVolume;

  /// No description provided for @dosingAdjustVolumeHint.
  ///
  /// In en, this message translates to:
  /// **'1 ~ 15; one decimal place'**
  String get dosingAdjustVolumeHint;

  /// No description provided for @dosingCompleteAdjust.
  ///
  /// In en, this message translates to:
  /// **'Complete Calibration'**
  String get dosingCompleteAdjust;

  /// No description provided for @dosingAdjusting.
  ///
  /// In en, this message translates to:
  /// **'Calibrating...'**
  String get dosingAdjusting;

  /// No description provided for @dosingAdjustVolumeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Drop volume cannot be empty'**
  String get dosingAdjustVolumeEmpty;

  /// No description provided for @dosingStartAdjustFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to start calibration'**
  String get dosingStartAdjustFailed;

  /// No description provided for @dosingAdjustSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Calibration successful'**
  String get dosingAdjustSuccessful;

  /// No description provided for @dosingAdjustFailed.
  ///
  /// In en, this message translates to:
  /// **'Calibration failed'**
  String get dosingAdjustFailed;

  /// No description provided for @homeSpinnerAllSink.
  ///
  /// In en, this message translates to:
  /// **'All Tanks'**
  String get homeSpinnerAllSink;

  /// No description provided for @homeSpinnerFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite Devices'**
  String get homeSpinnerFavorite;

  /// No description provided for @homeSpinnerUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unallocated Devices'**
  String get homeSpinnerUnassigned;

  /// No description provided for @dosingPumpHeadNoType.
  ///
  /// In en, this message translates to:
  /// **'No Type'**
  String get dosingPumpHeadNoType;

  /// No description provided for @dosingPumpHeadModeScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get dosingPumpHeadModeScheduled;

  /// No description provided for @dosingPumpHeadModeFree.
  ///
  /// In en, this message translates to:
  /// **'Free Mode'**
  String get dosingPumpHeadModeFree;

  /// No description provided for @dosingVolumeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter volume'**
  String get dosingVolumeHint;

  /// No description provided for @noRecords.
  ///
  /// In en, this message translates to:
  /// **'No scheduled tasks'**
  String get noRecords;

  /// No description provided for @dosingManualStarted.
  ///
  /// In en, this message translates to:
  /// **'Dosing started for head {headId}'**
  String dosingManualStarted(String headId);

  /// No description provided for @dosingVolumeFormat.
  ///
  /// In en, this message translates to:
  /// **'{dispensed} / {target} ml'**
  String dosingVolumeFormat(String dispensed, String target);

  /// No description provided for @channelPercentageFormat.
  ///
  /// In en, this message translates to:
  /// **'{label} {percentage}%'**
  String channelPercentageFormat(String label, int percentage);

  /// No description provided for @timeRangeSeparator.
  ///
  /// In en, this message translates to:
  /// **'~'**
  String get timeRangeSeparator;

  /// Dosing volume label with unit
  ///
  /// In en, this message translates to:
  /// **'Dosing Volume (ml)'**
  String get dosingVolume;

  /// Dosing start time label
  ///
  /// In en, this message translates to:
  /// **'Dosing Start Time'**
  String get dosingStartTime;

  /// Dosing end time label
  ///
  /// In en, this message translates to:
  /// **'Dosing End Time'**
  String get dosingEndTime;

  /// Number of dosing times
  ///
  /// In en, this message translates to:
  /// **'Dosing Frequency'**
  String get dosingFrequency;

  /// Type of dosing (additive type)
  ///
  /// In en, this message translates to:
  /// **'Dosing Type'**
  String get dosingType;

  /// Type of schedule (24hr/single/custom)
  ///
  /// In en, this message translates to:
  /// **'Schedule Type'**
  String get dosingScheduleType;

  /// Schedule time period
  ///
  /// In en, this message translates to:
  /// **'Schedule Period'**
  String get dosingSchedulePeriod;

  /// Days of week for dosing
  ///
  /// In en, this message translates to:
  /// **'Weekly Dosing Days'**
  String get dosingWeeklyDays;

  /// Execute dosing immediately
  ///
  /// In en, this message translates to:
  /// **'Execute Now'**
  String get dosingExecuteNow;

  /// Time for dosing execution
  ///
  /// In en, this message translates to:
  /// **'Execution Time'**
  String get dosingExecutionTime;

  /// Pump head rotating speed label
  ///
  /// In en, this message translates to:
  /// **'Pump Head Speed'**
  String get pumpHeadSpeed;

  /// Low rotating speed
  ///
  /// In en, this message translates to:
  /// **'Low Speed'**
  String get pumpHeadSpeedLow;

  /// Medium rotating speed
  ///
  /// In en, this message translates to:
  /// **'Medium Speed'**
  String get pumpHeadSpeedMedium;

  /// High rotating speed
  ///
  /// In en, this message translates to:
  /// **'High Speed'**
  String get pumpHeadSpeedHigh;

  /// Default rotating speed
  ///
  /// In en, this message translates to:
  /// **'Default Speed'**
  String get pumpHeadSpeedDefault;

  /// Title for calibration instructions section
  ///
  /// In en, this message translates to:
  /// **'Calibration Instructions'**
  String get calibrationInstructions;

  /// Step-by-step calibration instructions
  ///
  /// In en, this message translates to:
  /// **'1.Prepare the included measuring cup and some tubes\n2. Start manual operation to fill the tubes with liquid\n3. Select the speed for calibration'**
  String get calibrationSteps;

  /// Hint for calibration volume input
  ///
  /// In en, this message translates to:
  /// **'1 ~ 15; one decimal place'**
  String get calibrationVolumeHint;

  /// Calibration in progress message
  ///
  /// In en, this message translates to:
  /// **'Calibrating...'**
  String get calibrating;

  /// Button text to complete calibration
  ///
  /// In en, this message translates to:
  /// **'Complete Calibration'**
  String get calibrationComplete;

  /// Title for recent calibration records section
  ///
  /// In en, this message translates to:
  /// **'Recent Calibration Records'**
  String get recentCalibrationRecords;

  /// Today's total scheduled dosing volume
  ///
  /// In en, this message translates to:
  /// **'Today\'s Scheduled Immediate Dosing Volume'**
  String get todayScheduledVolume;

  /// Maximum daily dosing volume setting
  ///
  /// In en, this message translates to:
  /// **'Daily Max Dosing Volume'**
  String get maxDosingVolume;

  /// Hint for max dosing volume setting
  ///
  /// In en, this message translates to:
  /// **'Limit dosing volume for scheduled and non-scheduled operation after opening'**
  String get maxDosingVolumeHint;

  /// 1 minute delay option
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get delayTime1Min;

  /// Dosing settings page title
  ///
  /// In en, this message translates to:
  /// **'Dosing Pump Settings'**
  String get dosingSettingsTitle;

  /// Pump head record/schedule title
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get pumpHeadRecordTitle;

  /// Pump head record settings page title
  ///
  /// In en, this message translates to:
  /// **'Schedule Settings'**
  String get pumpHeadRecordSettingsTitle;

  /// Pump head record time settings page title
  ///
  /// In en, this message translates to:
  /// **'Period Settings'**
  String get pumpHeadRecordTimeSettingsTitle;

  /// Pump head adjust list page title
  ///
  /// In en, this message translates to:
  /// **'Adjust List'**
  String get pumpHeadAdjustListTitle;

  /// Pump head adjust page title
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get pumpHeadAdjustTitle;

  /// Dosing type page title
  ///
  /// In en, this message translates to:
  /// **'Dosing Type'**
  String get dosingTypeTitle;

  /// Rotating speed label
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get rotatingSpeed;

  /// Initial LED intensity setting
  ///
  /// In en, this message translates to:
  /// **'Initial Intensity'**
  String get ledInitialIntensity;

  /// Sunrise lighting effect
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get ledSunrise;

  /// Sunset lighting effect
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get ledSunset;

  /// Slow start / soft start feature
  ///
  /// In en, this message translates to:
  /// **'Soft Start'**
  String get ledSlowStart;

  /// Initial duration (30 minutes)
  ///
  /// In en, this message translates to:
  /// **'30 Minutes'**
  String get ledInitDuration;

  /// Scheduled time point in LED record
  ///
  /// In en, this message translates to:
  /// **'Scheduled Time Point'**
  String get ledScheduleTimePoint;

  /// LED schedule settings page title
  ///
  /// In en, this message translates to:
  /// **'Schedule Settings'**
  String get ledScheduleSettings;

  /// Add new LED scene
  ///
  /// In en, this message translates to:
  /// **'Add Scene'**
  String get ledSceneAdd;

  /// Edit LED scene settings
  ///
  /// In en, this message translates to:
  /// **'Scene Settings'**
  String get ledSceneEdit;

  /// Delete LED scene
  ///
  /// In en, this message translates to:
  /// **'Delete Scene'**
  String get ledSceneDelete;

  /// LED record paused message
  ///
  /// In en, this message translates to:
  /// **'The schedule is paused.'**
  String get ledRecordPause;

  /// LED record continue message
  ///
  /// In en, this message translates to:
  /// **'Resume execution.'**
  String get ledRecordContinue;

  /// Edit action button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// None/Empty option
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get generalNone;

  /// Complete/Done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionComplete;

  /// Run/Execute action button
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get actionRun;

  /// Device not connected message
  ///
  /// In en, this message translates to:
  /// **'Device not connected'**
  String get deviceNotConnected;

  /// Empty state message for sink list
  ///
  /// In en, this message translates to:
  /// **'Tap the add button at the bottom right to add a tank.'**
  String get sinkEmptyMessage;

  /// Bottom sheet title for adding tank
  ///
  /// In en, this message translates to:
  /// **'Add Tank'**
  String get bottomSheetAddSinkTitle;

  /// Field label for tank name
  ///
  /// In en, this message translates to:
  /// **'Tank Name'**
  String get bottomSheetAddSinkFieldTitle;

  /// Bottom sheet title for editing tank
  ///
  /// In en, this message translates to:
  /// **'Tank Settings'**
  String get bottomSheetEditSinkTitle;

  /// Field label for tank name
  ///
  /// In en, this message translates to:
  /// **'Tank Name'**
  String get bottomSheetEditSinkFieldTitle;

  /// Bottom sheet title for adding dosing type
  ///
  /// In en, this message translates to:
  /// **'Add Custom Dosing'**
  String get bottomSheetAddDropTypeTitle;

  /// Field label for dosing type name
  ///
  /// In en, this message translates to:
  /// **'Dosing Name'**
  String get bottomSheetAddDropTypeFieldTitle;

  /// Bottom sheet title for editing dosing type
  ///
  /// In en, this message translates to:
  /// **'Edit Custom Dosing'**
  String get bottomSheetEditDropTypeTitle;

  /// Field label for dosing type name
  ///
  /// In en, this message translates to:
  /// **'Dosing Name'**
  String get bottomSheetEditDropTypeFieldTitle;

  /// No description provided for @dosingVolumeRangeHint.
  ///
  /// In en, this message translates to:
  /// **'1 ~ 500'**
  String get dosingVolumeRangeHint;

  /// No description provided for @dropRecordTypeNone.
  ///
  /// In en, this message translates to:
  /// **'No Scheduled Tasks'**
  String get dropRecordTypeNone;

  /// No description provided for @dosingAdjustDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Calibration Date'**
  String get dosingAdjustDateTitle;

  /// No description provided for @dosingAdjustVolumeTitle.
  ///
  /// In en, this message translates to:
  /// **'Measured Volume'**
  String get dosingAdjustVolumeTitle;

  /// No description provided for @groupPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Group A'**
  String get groupPlaceholder;

  /// No description provided for @ledChartPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Chart Placeholder'**
  String get ledChartPlaceholder;

  /// No description provided for @ledSpectrumChartPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Spectrum Chart Placeholder'**
  String get ledSpectrumChartPlaceholder;

  /// No description provided for @ledTimePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'07:27'**
  String get ledTimePlaceholder;

  /// No description provided for @dosingRecordTimePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'08:00'**
  String get dosingRecordTimePlaceholder;

  /// No description provided for @dosingRecordEndTimePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'10:00'**
  String get dosingRecordEndTimePlaceholder;

  /// No description provided for @dosingRecordDetailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'50 ml / 5 times'**
  String get dosingRecordDetailPlaceholder;

  /// No description provided for @dosingTypeNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Type A'**
  String get dosingTypeNamePlaceholder;

  /// No description provided for @dosingTypeNamePlaceholderB.
  ///
  /// In en, this message translates to:
  /// **'Type B'**
  String get dosingTypeNamePlaceholderB;

  /// No description provided for @dosingTypeNamePlaceholderC.
  ///
  /// In en, this message translates to:
  /// **'Type C'**
  String get dosingTypeNamePlaceholderC;

  /// No description provided for @dosingRecordTimeRangePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'2022-10-14 ~ 2022-10-31'**
  String get dosingRecordTimeRangePlaceholder;

  /// No description provided for @dosingRecordTimePointPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'2022-10-14 10:20:13'**
  String get dosingRecordTimePointPlaceholder;

  /// No description provided for @dosingAdjustDatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'2024-01-01 12:00:00'**
  String get dosingAdjustDatePlaceholder;

  /// No description provided for @dosingAdjustVolumePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'10.0 ml'**
  String get dosingAdjustVolumePlaceholder;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'id',
    'ja',
    'ko',
    'pt',
    'ru',
    'th',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
