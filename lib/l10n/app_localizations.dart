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
  /// **'Connect via Bluetooth to continue.'**
  String get bleDisconnectedWarning;

  /// No description provided for @bleGuardDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth required'**
  String get bleGuardDialogTitle;

  /// No description provided for @bleGuardDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Connect to a device to access this feature.'**
  String get bleGuardDialogMessage;

  /// No description provided for @bleGuardDialogButton.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get bleGuardDialogButton;

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

  /// No description provided for @deviceHeader.
  ///
  /// In en, this message translates to:
  /// **'My devices'**
  String get deviceHeader;

  /// No description provided for @deviceEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No devices yet'**
  String get deviceEmptyTitle;

  /// No description provided for @deviceEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the Bluetooth tab to discover hardware.'**
  String get deviceEmptySubtitle;

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
  /// **'Remove devices?'**
  String get deviceDeleteConfirmTitle;

  /// No description provided for @deviceDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'The selected devices will be removed from this phone. This does not reset the hardware.'**
  String get deviceDeleteConfirmMessage;

  /// No description provided for @deviceDeleteConfirmPrimary.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get deviceDeleteConfirmPrimary;

  /// No description provided for @deviceDeleteConfirmSecondary.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get deviceDeleteConfirmSecondary;

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
  /// **'Enter the amount in milliliters.'**
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
  /// **'Enter a dose greater than zero.'**
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
  /// **'Enter a schedule name.'**
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
  /// **'Lighting schedule saved.'**
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

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @errorDeviceBusy.
  ///
  /// In en, this message translates to:
  /// **'Device is busy. Try again shortly.'**
  String get errorDeviceBusy;

  /// No description provided for @errorNoDevice.
  ///
  /// In en, this message translates to:
  /// **'No active device.'**
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

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please retry.'**
  String get errorGeneric;

  /// No description provided for @snackbarDeviceRemoved.
  ///
  /// In en, this message translates to:
  /// **'Devices removed.'**
  String get snackbarDeviceRemoved;

  /// No description provided for @snackbarDeviceConnected.
  ///
  /// In en, this message translates to:
  /// **'Device connected.'**
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
  /// **'Manual dose sent.'**
  String get dosingPumpHeadManualDoseSuccess;

  /// No description provided for @dosingPumpHeadTimedDose.
  ///
  /// In en, this message translates to:
  /// **'Schedule timed dose'**
  String get dosingPumpHeadTimedDose;

  /// No description provided for @dosingPumpHeadTimedDoseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Timed dose scheduled.'**
  String get dosingPumpHeadTimedDoseSuccess;

  /// No description provided for @dosingPumpHeadCalibrate.
  ///
  /// In en, this message translates to:
  /// **'Calibrate head'**
  String get dosingPumpHeadCalibrate;

  /// No description provided for @dosingPumpHeadPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'No dosing data yet.'**
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
  /// **'No dosing data yet.'**
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
  /// **'24h average schedule sent.'**
  String get dosingScheduleApplyDailyAverageSuccess;

  /// No description provided for @dosingScheduleApplyCustomWindow.
  ///
  /// In en, this message translates to:
  /// **'Apply custom window schedule'**
  String get dosingScheduleApplyCustomWindow;

  /// No description provided for @dosingScheduleApplyCustomWindowSuccess.
  ///
  /// In en, this message translates to:
  /// **'Custom window schedule sent.'**
  String get dosingScheduleApplyCustomWindowSuccess;

  /// No description provided for @dosingScheduleViewButton.
  ///
  /// In en, this message translates to:
  /// **'View schedules'**
  String get dosingScheduleViewButton;

  /// No description provided for @dosingScheduleEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No schedule configured'**
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
  /// **'Name can\'t be empty.'**
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
  /// **'Keep editing'**
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
  /// **'Paused'**
  String get dosingScheduleStatusDisabled;

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
