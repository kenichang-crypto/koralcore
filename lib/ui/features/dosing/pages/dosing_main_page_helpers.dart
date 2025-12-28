import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../domain/doser_dosing/pump_speed.dart';
import '../../../../domain/doser_dosing/single_dose_immediate.dart';
import '../../../components/app_error_presenter.dart';
import '../../../theme/reef_colors.dart';

void confirmDeleteDevice(
  BuildContext context,
  AppSession session,
  AppContext appContext,
) async {
  final l10n = AppLocalizations.of(context);
  final deviceId = session.activeDeviceId;

  if (deviceId == null) {
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.deviceDeleteConfirmTitle),
      content: Text(l10n.deviceDeleteConfirmMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.deviceDeleteConfirmSecondary),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.deviceDeleteConfirmPrimary),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    try {
      await appContext.removeDeviceUseCase.execute(deviceId: deviceId);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.snackbarDeviceRemoved)));
      }
    } on AppError catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(describeAppError(l10n, error.code))),
        );
      }
    }
  }
}

void confirmResetDevice(
  BuildContext context,
  AppSession session,
  AppContext appContext,
) async {
  final l10n = AppLocalizations.of(context);
  final deviceId = session.activeDeviceId;

  if (deviceId == null) {
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.dosingResetDevice),
      content: Text(
        'Are you sure you want to reset this device to default settings? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.deviceDeleteConfirmSecondary),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(backgroundColor: ReefColors.error),
          child: Text(l10n.dosingResetDevice),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    try {
      await appContext.resetDosingStateUseCase.execute(deviceId: deviceId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.dosingResetDeviceSuccess,
            ),
          ),
        );
      }
    } on AppError catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(describeAppError(l10n, error.code))),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset device: ${error.toString()}'),
          ),
        );
      }
    }
  }
}

Future<void> handlePlayDosing(
  BuildContext context,
  AppSession session,
  AppContext appContext,
  String headId,
) async {
  final l10n = AppLocalizations.of(context);
  final deviceId = session.activeDeviceId;

  if (deviceId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(describeAppError(l10n, AppErrorCode.noActiveDevice)),
      ),
    );
    return;
  }

  // Default dose: 1.0 ml (can be made configurable)
  const double defaultDoseMl = 1.0;
  final int pumpId = _pumpIdFromHeadId(headId);

  try {
    final SingleDoseImmediate dose = SingleDoseImmediate(
      pumpId: pumpId,
      doseMl: defaultDoseMl,
      speed: PumpSpeed.medium,
    );

    await appContext.singleDoseImmediateUseCase.execute(
      deviceId: deviceId,
      dose: dose,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dosing started for head $headId')),
      );
    }
  } on AppError catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(describeAppError(l10n, error.code))),
      );
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start dosing: ${error.toString()}')),
      );
    }
  }
}

int _pumpIdFromHeadId(String headId) {
  switch (headId.toUpperCase()) {
    case 'A':
      return 0;
    case 'B':
      return 1;
    case 'C':
      return 2;
    case 'D':
      return 3;
    default:
      return 0;
  }
}

Future<void> handleConnect(
  BuildContext context,
  AppSession session,
  AppContext appContext,
) async {
  final l10n = AppLocalizations.of(context);
  final deviceId = session.activeDeviceId;

  if (deviceId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(describeAppError(l10n, AppErrorCode.noActiveDevice)),
      ),
    );
    return;
  }

  try {
    await appContext.connectDeviceUseCase.execute(deviceId: deviceId);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Device connected successfully')));
    }
  } on AppError catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(describeAppError(l10n, error.code))),
      );
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect: ${error.toString()}')),
      );
    }
  }
}

Future<void> handleDisconnect(
  BuildContext context,
  AppSession session,
  AppContext appContext,
) async {
  final l10n = AppLocalizations.of(context);
  final deviceId = session.activeDeviceId;

  if (deviceId == null) {
    return;
  }

  try {
    await appContext.disconnectDeviceUseCase.execute(deviceId: deviceId);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Device disconnected')));
    }
  } on AppError catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(describeAppError(l10n, error.code))),
      );
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to disconnect: ${error.toString()}')),
      );
    }
  }
}
