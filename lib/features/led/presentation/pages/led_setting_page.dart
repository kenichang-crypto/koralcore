import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_error.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../sink/presentation/pages/sink_position_page.dart';

/// LedSettingPage
///
/// Parity with reef-b-app LedSettingActivity (activity_led_setting.xml)
class LedSettingPage extends StatelessWidget {
  const LedSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LedSettingView();
  }
}

class _LedSettingView extends StatefulWidget {
  const _LedSettingView();

  @override
  State<_LedSettingView> createState() => _LedSettingViewState();
}

class _LedSettingViewState extends State<_LedSettingView> {
  late TextEditingController _nameController;
  bool _isSaving = false;
  String? _sinkId;
  String? _sinkName;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = context.read<AppSession>();
    if (_nameController.text.isEmpty && session.activeDeviceName != null) {
      _nameController.text = session.activeDeviceName!;
      _nameController.selection = TextSelection.collapsed(
        offset: _nameController.text.length,
      );
    }
    _loadDeviceSink(session.activeDeviceId);
  }

  Future<void> _loadDeviceSink(String? deviceId) async {
    if (deviceId == null) return;
    final appContext = context.read<AppContext>();
    final deviceData = await appContext.deviceRepository.getDevice(deviceId);
    if (!mounted) return;
    final sinkId = deviceData?['sinkId']?.toString();
    if (sinkId != _sinkId) {
      setState(() {
        _sinkId = sinkId;
        if (sinkId != null) {
          final sinks = appContext.sinkRepository.getCurrentSinks();
          _sinkName = sinks.where((s) => s.id == sinkId).firstOrNull?.name;
        } else {
          _sinkName = null;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<AppSession>();
    final appContext = context.read<AppContext>();
    final deviceName = session.activeDeviceName ?? '';

    if (_nameController.text.isEmpty && deviceName.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _nameController.text.isEmpty) {
          _nameController.text = deviceName;
        }
      });
    }

    return Stack(
      children: [
        Column(
          children: [
            _ToolbarTwoAction(
              l10n: l10n,
              session: session,
              nameController: _nameController,
              isSaving: _isSaving,
              onCancel: () => Navigator.of(context).pop(),
              onSave: () async {
                final deviceId = session.activeDeviceId;
                if (deviceId == null) return;
                final name = _nameController.text.trim();
                if (name.isEmpty) {
                  showErrorSnackBar(
                    context,
                    AppErrorCode.invalidParam,
                    customMessage: 'Device name must not be empty',
                  );
                  return;
                }
                setState(() => _isSaving = true);
                try {
                  await appContext.updateDeviceNameUseCase.execute(
                    deviceId: deviceId,
                    name: name,
                  );
                  if (mounted) {
                    Navigator.of(context).pop(true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.deviceSettingsSaved)),
                    );
                  }
                } on AppError catch (e) {
                  if (mounted) {
                    showErrorSnackBar(context, e.code);
                  }
                } catch (_) {
                  if (mounted) {
                    showErrorSnackBar(context, AppErrorCode.unknownError);
                  }
                } finally {
                  if (mounted) setState(() => _isSaving = false);
                }
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  top: 12,
                  right: 16,
                  bottom: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DeviceNameSection(
                      l10n: l10n,
                      controller: _nameController,
                      enabled: !_isSaving,
                    ),
                    const SizedBox(height: 16),
                    _SinkPositionSection(
                      l10n: l10n,
                      sinkName: _sinkName,
                      enabled: !_isSaving,
                      onTap: () async {
                        final deviceId = session.activeDeviceId;
                        if (deviceId == null) return;
                        final result = await Navigator.of(context).push<String?>(
                          MaterialPageRoute(
                            builder: (_) => SinkPositionPage(
                              initialSinkId: _sinkId,
                            ),
                          ),
                        );
                        if (!mounted || result == null) return;
                        final deviceData =
                            await appContext.deviceRepository.getDevice(deviceId);
                        try {
                          await appContext.updateDeviceSinkUseCase.execute(
                            deviceId: deviceId,
                            newSinkId: result.isEmpty ? null : result,
                            currentSinkId: _sinkId,
                            deviceType: 'LED',
                            currentGroup: deviceData?['group']?.toString(),
                            currentMaster: deviceData?['isMaster'] as bool?,
                          );
                          if (mounted) {
                            setState(() {
                              _sinkId = result.isEmpty ? null : result;
                              if (_sinkId != null) {
                                final sinks =
                                    appContext.sinkRepository.getCurrentSinks();
                                _sinkName = sinks
                                    .where((s) => s.id == _sinkId)
                                    .firstOrNull
                                    ?.name;
                              } else {
                                _sinkName = null;
                              }
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.deviceSettingsSaved)),
                            );
                          }
                        } on AppError catch (e) {
                          if (mounted) showErrorSnackBar(context, e.code);
                        } catch (_) {
                          if (mounted) {
                            showErrorSnackBar(
                                context, AppErrorCode.unknownError);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// A. Toolbar (fixed) ↔ toolbar_two_action.xml
// ────────────────────────────────────────────────────────────────────────────

class _ToolbarTwoAction extends StatelessWidget {
  const _ToolbarTwoAction({
    required this.l10n,
    required this.session,
    required this.nameController,
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
  });

  final AppLocalizations l10n;
  final AppSession session;
  final TextEditingController nameController;
  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final canSave = session.isReady &&
        !isSaving &&
        nameController.text.trim().isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: Colors.white,
          height: 56,
          child: Row(
            children: [
              TextButton(
                onPressed: isSaving ? null : onCancel,
                child: Text(
                  l10n.actionCancel,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                l10n.ledSettingTitle,
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: canSave ? onSave : null,
                child: Text(
                  l10n.actionSave,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(height: 2, color: AppColors.divider),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// B1. Device Name Section ↔ tv_device_name_title + layout_name + edt_name
// ────────────────────────────────────────────────────────────────────────────

class _DeviceNameSection extends StatelessWidget {
  const _DeviceNameSection({
    required this.l10n,
    required this.controller,
    required this.enabled,
  });

  final AppLocalizations l10n;
  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.deviceName,
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceMuted,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xs),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xs),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xs),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          maxLines: 1,
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// B2. Sink Position Section ↔ tv_device_position_title + btn_position
// ────────────────────────────────────────────────────────────────────────────

class _SinkPositionSection extends StatelessWidget {
  const _SinkPositionSection({
    required this.l10n,
    required this.sinkName,
    required this.enabled,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final String? sinkName;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final displayText = sinkName ?? l10n.sinkPositionNotSet;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.sinkPosition,
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        MaterialButton(
          onPressed: enabled ? onTap : null,
          color: AppColors.surfaceMuted,
          elevation: 0,
          disabledColor: AppColors.surfaceMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  displayText,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ),
              CommonIconHelper.getNextIcon(
                size: 20,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// C. Progress overlay ↔ progress.xml
// ────────────────────────────────────────────────────────────────────────────

class _ProgressOverlay extends StatelessWidget {
  const _ProgressOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
