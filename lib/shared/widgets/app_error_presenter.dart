import '../../../../app/common/app_error_code.dart';
import 'package:koralcore/l10n/app_localizations.dart';

String describeAppError(AppLocalizations l10n, AppErrorCode code) {
  switch (code) {
    case AppErrorCode.deviceBusy:
      return l10n.errorDeviceBusy;
    case AppErrorCode.noActiveDevice:
      return l10n.errorNoDevice;
    case AppErrorCode.notSupported:
      return l10n.errorNotSupported;
    case AppErrorCode.invalidParam:
      return l10n.errorInvalidParam;
    case AppErrorCode.ledMasterCannotDelete:
      return l10n.errorLedMasterCannotDelete;
    case AppErrorCode.transportError:
      return l10n.errorTransport;
    case AppErrorCode.sinkFull:
      return l10n.errorSinkFull;
    case AppErrorCode.connectLimit:
      return l10n.errorConnectLimit;
    case AppErrorCode.unknownError:
    default:
      return l10n.errorGeneric;
  }
}
