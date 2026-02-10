library;

import '../../data/ble/ble_adapter.dart';
import '../../data/ble/ble_adapter_impl.dart';
import '../../data/ble/ble_notify_bus.dart';
import '../../data/ble/doser/ble_today_totals_data_source.dart';
import '../../data/ble/doser/today_totals_data_source.dart';
import '../../data/ble/platform_channels/ble_platform_transport_writer.dart';
import '../../data/ble/schedule/led/led_schedule_command_builder.dart';
import '../../data/ble/schedule/schedule_sender.dart';
import '../../data/ble/transport/ble_read_transport.dart';
import '../../data/ble/transport/ble_transport_log_buffer.dart';
import '../../data/dosing/ble_dosing_repository_impl.dart';
import '../../data/led/ble_led_repository_impl.dart';
import '../../data/repositories/device_repository_impl.dart';
import '../../data/repositories/doser_repository_impl.dart';
import '../../data/repositories/lighting_repository_impl.dart';
import '../../data/repositories/pump_head_repository_impl.dart';
import '../../data/repositories/sink_repository_impl.dart';
import '../../data/repositories/scene_repository_impl.dart';
import '../../data/ble/led/led_command_builder.dart';
import '../../platform/contracts/device_repository.dart';
import '../../data/repositories/system_repository_impl.dart';
import '../../platform/contracts/device_repository.dart';
import '../../platform/contracts/dosing_port.dart';
import '../../platform/contracts/dosing_repository.dart';
import '../../platform/contracts/drop_type_repository.dart';
import '../../platform/contracts/led_port.dart';
import '../../platform/contracts/led_record_repository.dart';
import '../../platform/contracts/led_repository.dart';
import '../../platform/contracts/pump_head_repository.dart';
import '../../platform/contracts/sink_repository.dart';
import '../../platform/contracts/system_repository.dart';
import '../../platform/contracts/warning_repository.dart';
import '../../platform/contracts/drop_type_repository.dart';
import '../../data/repositories/warning_repository_impl.dart';
import '../../data/repositories/drop_type_repository_impl.dart';
import '../common/app_error_mapper.dart';
import '../device/connect_device_usecase.dart';
import '../device/device_connection_coordinator.dart';
import '../device/disconnect_device_usecase.dart';
import '../device/initialize_device_usecase.dart';
import '../device/remove_device_usecase.dart';
import '../device/scan_devices_usecase.dart';
import '../device/toggle_favorite_device_usecase.dart';
import '../device/update_device_name_usecase.dart';
import '../device/update_device_sink_usecase.dart';
import '../../domain/usecases/doser/apply_schedule_usecase.dart';
import '../../domain/usecases/doser/observe_dosing_state_usecase.dart';
import '../../domain/usecases/doser/read_calibration_history.dart';
import '../../domain/usecases/doser/read_dosing_schedule_summary_usecase.dart';
import '../../domain/usecases/doser/read_dosing_state_usecase.dart';
import '../../domain/usecases/doser/read_schedule.dart';
import '../../domain/usecases/doser/read_today_total.dart';
import '../../domain/usecases/doser/single_dose_immediate_usecase.dart';
import '../../domain/usecases/doser/single_dose_timed_usecase.dart';
import '../../domain/usecases/doser/schedule_capability_guard.dart';
import '../../domain/usecases/doser/schedule_result_mapper.dart';
import '../../domain/usecases/doser/update_pump_head_settings.dart';
import '../../domain/usecases/doser/reset_dosing_state_usecase.dart';
import '../../domain/usecases/led/apply_led_schedule_usecase.dart';
import '../../domain/usecases/led/apply_scene_usecase.dart';
import '../../domain/usecases/led/clear_led_records_usecase.dart';
import '../../domain/usecases/led/delete_led_record_usecase.dart';
import '../../domain/usecases/led/led_schedule_capability_guard.dart';
import '../../domain/usecases/led/led_schedule_result_mapper.dart';
import '../../domain/usecases/led/observe_led_record_state_usecase.dart';
import '../../domain/usecases/led/observe_led_state_usecase.dart';
import '../../domain/usecases/led/read_led_record_state_usecase.dart';
import '../../domain/usecases/led/read_led_schedule_summary_usecase.dart';
import '../../domain/usecases/led/read_led_schedules.dart';
import '../../domain/usecases/led/read_led_state_usecase.dart';
import '../../domain/usecases/led/read_led_scenes.dart';
import '../../domain/usecases/led/read_lighting_state.dart';
import '../../domain/usecases/led/refresh_led_record_state_usecase.dart';
import '../../domain/usecases/led/reset_led_state_usecase.dart';
import '../../domain/usecases/led/save_led_schedule_usecase.dart';
import '../../domain/usecases/led/set_channel_intensity.dart';
import '../../domain/usecases/led/start_led_preview_usecase.dart';
import '../../domain/usecases/led/start_led_record_usecase.dart';
import '../../domain/usecases/led/init_led_record_usecase.dart';
import '../../domain/usecases/led/stop_led_preview_usecase.dart';
import '../../domain/usecases/led/add_scene_usecase.dart';
import '../../domain/usecases/led/update_scene_usecase.dart';
import '../../domain/usecases/led/delete_scene_usecase.dart';
import '../../domain/usecases/led/enter_dimming_mode_usecase.dart';
import '../../domain/usecases/led/exit_dimming_mode_usecase.dart';
import '../session/current_device_session.dart';

/// Root dependency graph for the UI layer.
class AppContext {
  final DeviceRepository deviceRepository;
  final LedRepository ledRepository;
  final LedRecordRepository ledRecordRepository;
  final DosingRepository dosingRepository;
  final PumpHeadRepository pumpHeadRepository;
  final SinkRepository sinkRepository;
  final WarningRepository warningRepository;
  final DropTypeRepository dropTypeRepository;
  final CurrentDeviceSession currentDeviceSession;
  final BleAdapter bleAdapter;

  final ScanDevicesUseCase scanDevicesUseCase;
  final ConnectDeviceUseCase connectDeviceUseCase;
  final DisconnectDeviceUseCase disconnectDeviceUseCase;
  final InitializeDeviceUseCase initializeDeviceUseCase;
  final RemoveDeviceUseCase removeDeviceUseCase;
  final ToggleFavoriteDeviceUseCase toggleFavoriteDeviceUseCase;
  final UpdateDeviceNameUseCase updateDeviceNameUseCase;
  final UpdateDeviceSinkUseCase updateDeviceSinkUseCase;
  final ReadScheduleUseCase readScheduleUseCase;
  final ReadTodayTotalUseCase readTodayTotalUseCase;
  final ReadDosingScheduleSummaryUseCase readDosingScheduleSummaryUseCase;
  final ReadCalibrationHistoryUseCase readCalibrationHistoryUseCase;
  final ReadLedScenesUseCase readLedScenesUseCase;
  final ReadLedScheduleUseCase readLedScheduleUseCase;
  final ReadLedScheduleSummaryUseCase readLedScheduleSummaryUseCase;
  final SaveLedScheduleUseCase saveLedScheduleUseCase;
  final ReadLightingStateUseCase readLightingStateUseCase;
  final SetChannelIntensityUseCase setChannelIntensityUseCase;
  final ApplySceneUseCase applySceneUseCase;
  final ResetLedStateUseCase resetLedStateUseCase;
  final ResetDosingStateUseCase resetDosingStateUseCase;
  final UpdatePumpHeadSettingsUseCase updatePumpHeadSettingsUseCase;
  final SingleDoseImmediateUseCase singleDoseImmediateUseCase;
  final SingleDoseTimedUseCase singleDoseTimedUseCase;
  final ApplyScheduleUseCase applyScheduleUseCase;
  final ApplyLedScheduleUseCase applyLedScheduleUseCase;
  final ObserveLedStateUseCase observeLedStateUseCase;
  final ReadLedStateUseCase readLedStateUseCase;
  final ObserveDosingStateUseCase observeDosingStateUseCase;
  final ReadDosingStateUseCase readDosingStateUseCase;
  final ObserveLedRecordStateUseCase observeLedRecordStateUseCase;
  final ReadLedRecordStateUseCase readLedRecordStateUseCase;
  final RefreshLedRecordStateUseCase refreshLedRecordStateUseCase;
  final DeleteLedRecordUseCase deleteLedRecordUseCase;
  final ClearLedRecordsUseCase clearLedRecordsUseCase;
  final StartLedPreviewUseCase startLedPreviewUseCase;
  final StopLedPreviewUseCase stopLedPreviewUseCase;
  final StartLedRecordUseCase startLedRecordUseCase;
  final InitLedRecordUseCase initLedRecordUseCase;
  final AddSceneUseCase addSceneUseCase;
  final UpdateSceneUseCase updateSceneUseCase;
  final DeleteSceneUseCase deleteSceneUseCase;
  final EnterDimmingModeUseCase enterDimmingModeUseCase;
  final ExitDimmingModeUseCase exitDimmingModeUseCase;

  final DeviceConnectionCoordinator _deviceConnectionCoordinator;

  AppContext._({
    required this.deviceRepository,
    required this.ledRepository,
    required this.ledRecordRepository,
    required this.dosingRepository,
    required this.pumpHeadRepository,
    required this.sinkRepository,
    required this.warningRepository,
    required this.dropTypeRepository,
    required this.currentDeviceSession,
    required this.bleAdapter,
    required this.scanDevicesUseCase,
    required this.connectDeviceUseCase,
    required this.disconnectDeviceUseCase,
    required this.initializeDeviceUseCase,
    required this.removeDeviceUseCase,
    required this.toggleFavoriteDeviceUseCase,
    required this.updateDeviceNameUseCase,
    required this.updateDeviceSinkUseCase,
    required this.readScheduleUseCase,
    required this.readTodayTotalUseCase,
    required this.readDosingScheduleSummaryUseCase,
    required this.readCalibrationHistoryUseCase,
    required this.readLedScenesUseCase,
    required this.readLedScheduleUseCase,
    required this.readLedScheduleSummaryUseCase,
    required this.saveLedScheduleUseCase,
    required this.readLightingStateUseCase,
    required this.setChannelIntensityUseCase,
    required this.applySceneUseCase,
    required this.resetLedStateUseCase,
    required this.resetDosingStateUseCase,
    required this.updatePumpHeadSettingsUseCase,
    required this.singleDoseImmediateUseCase,
    required this.singleDoseTimedUseCase,
    required this.applyScheduleUseCase,
    required this.applyLedScheduleUseCase,
    required this.observeLedStateUseCase,
    required this.readLedStateUseCase,
    required this.observeLedRecordStateUseCase,
    required this.readLedRecordStateUseCase,
    required this.refreshLedRecordStateUseCase,
    required this.deleteLedRecordUseCase,
    required this.clearLedRecordsUseCase,
    required this.startLedPreviewUseCase,
    required this.stopLedPreviewUseCase,
    required this.startLedRecordUseCase,
    required this.initLedRecordUseCase,
    required this.addSceneUseCase,
    required this.updateSceneUseCase,
    required this.deleteSceneUseCase,
    required this.enterDimmingModeUseCase,
    required this.exitDimmingModeUseCase,
    required this.observeDosingStateUseCase,
    required this.readDosingStateUseCase,
    required DeviceConnectionCoordinator deviceConnectionCoordinator,
  }) : _deviceConnectionCoordinator = deviceConnectionCoordinator {
    _deviceConnectionCoordinator.start();
  }

  factory AppContext.bootstrap() {
    final SinkRepository sinkRepository = SinkRepositoryImpl();
    final DeviceRepository deviceRepository = DeviceRepositoryImpl(
      sinkRepository: sinkRepository,
    );
    final PumpHeadRepository pumpHeadRepository = PumpHeadRepositoryImpl();
    final WarningRepository warningRepository = WarningRepositoryImpl();
    final DropTypeRepository dropTypeRepository = DropTypeRepositoryImpl(
      pumpHeadRepository: pumpHeadRepository,
    );
    const LedPort ledPort = LightingRepositoryImpl();
    final currentDeviceSession = CurrentDeviceSession();
    final BleTransportLogBuffer transportLogBuffer = BleTransportLogBuffer();
    final BlePlatformTransportWriter platformTransportWriter =
        BlePlatformTransportWriter();
    BleNotifyBus.configure(platformTransportWriter);
    final BleAdapter bleAdapter = BleAdapterImpl(
      transportWriter: platformTransportWriter.write,
      observer: transportLogBuffer,
    );
    final BleLedRepositoryImpl bleLedRepository = BleLedRepositoryImpl(
      bleAdapter: bleAdapter,
      connectionStream: platformTransportWriter.connectionStateStream,
    );
    final LedRepository ledRepository = bleLedRepository;
    final LedRecordRepository ledRecordRepository = bleLedRepository;
    final BleDosingRepositoryImpl bleDosingRepository = BleDosingRepositoryImpl(
      bleAdapter: bleAdapter,
      connectionStream: platformTransportWriter.connectionStateStream,
    );
    final DosingRepository dosingRepository = bleDosingRepository;
    final BleReadTransport bleReadTransport = BleAdapterReadTransport(
      adapter: bleAdapter,
    );
    final TodayTotalsDataSource todayTotalsDataSource =
        BleTodayTotalsDataSource(transport: bleReadTransport);
    final DosingPort dosingPort = DoserRepositoryImpl(
      todayTotalsDataSource: todayTotalsDataSource,
    );
    final AppErrorMapper appErrorMapper = AppErrorMapper();
    const ScheduleCapabilityGuard scheduleCapabilityGuard =
        ScheduleCapabilityGuard();
    final ScheduleResultMapper scheduleResultMapper = ScheduleResultMapper(
      appErrorMapper: appErrorMapper,
    );
    const LedScheduleCapabilityGuard ledScheduleCapabilityGuard =
        LedScheduleCapabilityGuard();
    final LedScheduleResultMapper ledScheduleResultMapper =
        LedScheduleResultMapper(appErrorMapper: appErrorMapper);
    const LedScheduleCommandBuilder ledScheduleCommandBuilder =
        LedScheduleCommandBuilder();
    final ScheduleSender scheduleSender = ScheduleSender(
      bleAdapter: bleAdapter,
    );
    final ObserveLedStateUseCase observeLedStateUseCase =
        ObserveLedStateUseCase(ledRepository: ledRepository);
    final ReadLedStateUseCase readLedStateUseCase = ReadLedStateUseCase(
      ledRepository: ledRepository,
    );

    final ReadTodayTotalUseCase readTodayTotalUseCase = ReadTodayTotalUseCase(
      dosingPort: dosingPort,
      currentDeviceSession: currentDeviceSession,
      pumpHeadRepository: pumpHeadRepository,
    );

    final SystemRepository systemRepository = SystemRepositoryImpl();
    final InitializeDeviceUseCase initializeDeviceUseCase =
        InitializeDeviceUseCase(
          deviceRepository: deviceRepository,
          systemRepository: systemRepository,
          currentDeviceSession: currentDeviceSession,
          // Default resolver is used, which is fine for production.
          // Explicit injection would require creating the instance above.
        );

    return AppContext._(
      deviceRepository: deviceRepository,
      ledRepository: ledRepository,
      ledRecordRepository: ledRecordRepository,
      dosingRepository: dosingRepository,
      pumpHeadRepository: pumpHeadRepository,
      sinkRepository: sinkRepository,
      warningRepository: warningRepository,
      dropTypeRepository: dropTypeRepository,
      currentDeviceSession: currentDeviceSession,
      bleAdapter: bleAdapter,
      scanDevicesUseCase: ScanDevicesUseCase(
        deviceRepository: deviceRepository,
      ),
      connectDeviceUseCase: ConnectDeviceUseCase(
        deviceRepository: deviceRepository,
        currentDeviceSession: currentDeviceSession,
        initializeDeviceUseCase: initializeDeviceUseCase,
      ),
      disconnectDeviceUseCase: DisconnectDeviceUseCase(
        deviceRepository: deviceRepository,
        currentDeviceSession: currentDeviceSession,
      ),
      initializeDeviceUseCase: initializeDeviceUseCase,
      removeDeviceUseCase: RemoveDeviceUseCase(
        deviceRepository: deviceRepository,
        currentDeviceSession: currentDeviceSession,
        disconnectDeviceUseCase: DisconnectDeviceUseCase(
          deviceRepository: deviceRepository,
          currentDeviceSession: currentDeviceSession,
        ),
      ),
      toggleFavoriteDeviceUseCase: ToggleFavoriteDeviceUseCase(
        deviceRepository: deviceRepository,
      ),
      updateDeviceNameUseCase: UpdateDeviceNameUseCase(
        deviceRepository: deviceRepository,
      ),
      updateDeviceSinkUseCase: UpdateDeviceSinkUseCase(
        deviceRepository: deviceRepository,
      ),
      readScheduleUseCase: const ReadScheduleUseCase(),
      readTodayTotalUseCase: readTodayTotalUseCase,
      readDosingScheduleSummaryUseCase: ReadDosingScheduleSummaryUseCase(
        dosingPort: dosingPort,
        currentDeviceSession: currentDeviceSession,
      ),
      readCalibrationHistoryUseCase: const ReadCalibrationHistoryUseCase(),
      readLedScenesUseCase: ReadLedScenesUseCase(ledRepository: ledRepository),
      readLedScheduleUseCase: ReadLedScheduleUseCase(
        ledRepository: ledRepository,
      ),
      readLedScheduleSummaryUseCase: ReadLedScheduleSummaryUseCase(
        ledPort: ledPort,
        currentDeviceSession: currentDeviceSession,
      ),
      saveLedScheduleUseCase: const SaveLedScheduleUseCase.unavailable(),
      readLightingStateUseCase: ReadLightingStateUseCase(
        ledRepository: ledRepository,
      ),
      setChannelIntensityUseCase: SetChannelIntensityUseCase(
        ledRepository: ledRepository,
      ),
      applySceneUseCase: ApplySceneUseCase(
        ledRepository: ledRepository,
        currentDeviceSession: currentDeviceSession,
      ),
      resetLedStateUseCase: ResetLedStateUseCase(
        deviceRepository: deviceRepository,
        ledRepository: ledRepository,
      ),
      resetDosingStateUseCase: ResetDosingStateUseCase(
        deviceRepository: deviceRepository,
        dosingRepository: dosingRepository,
      ),
      updatePumpHeadSettingsUseCase: const UpdatePumpHeadSettingsUseCase(),
      singleDoseImmediateUseCase: SingleDoseImmediateUseCase(
        deviceRepository: deviceRepository,
        currentDeviceSession: currentDeviceSession,
        bleAdapter: bleAdapter,
        readTodayTotalUseCase: readTodayTotalUseCase,
        pumpHeadRepository: pumpHeadRepository,
      ),
      singleDoseTimedUseCase: SingleDoseTimedUseCase(
        deviceRepository: deviceRepository,
        currentDeviceSession: currentDeviceSession,
        bleAdapter: bleAdapter,
      ),
      applyScheduleUseCase: ApplyScheduleUseCase(
        deviceRepository: deviceRepository,
        pumpHeadRepository: pumpHeadRepository,
        scheduleCapabilityGuard: scheduleCapabilityGuard,
        scheduleResultMapper: scheduleResultMapper,
        currentDeviceSession: currentDeviceSession,
        scheduleSender: scheduleSender,
      ),
      applyLedScheduleUseCase: ApplyLedScheduleUseCase(
        ledRepository: ledRepository,
        ledScheduleCapabilityGuard: ledScheduleCapabilityGuard,
        ledScheduleResultMapper: ledScheduleResultMapper,
        ledScheduleCommandBuilder: ledScheduleCommandBuilder,
        currentDeviceSession: currentDeviceSession,
        bleAdapter: bleAdapter,
      ),
      observeLedStateUseCase: observeLedStateUseCase,
      readLedStateUseCase: readLedStateUseCase,
      observeDosingStateUseCase: ObserveDosingStateUseCase(
        dosingRepository: dosingRepository,
      ),
      readDosingStateUseCase: ReadDosingStateUseCase(
        dosingRepository: dosingRepository,
      ),
      observeLedRecordStateUseCase: ObserveLedRecordStateUseCase(
        repository: ledRecordRepository,
      ),
      readLedRecordStateUseCase: ReadLedRecordStateUseCase(
        repository: ledRecordRepository,
      ),
      refreshLedRecordStateUseCase: RefreshLedRecordStateUseCase(
        repository: ledRecordRepository,
      ),
      deleteLedRecordUseCase: DeleteLedRecordUseCase(
        repository: ledRecordRepository,
      ),
      clearLedRecordsUseCase: ClearLedRecordsUseCase(
        repository: ledRecordRepository,
      ),
      startLedPreviewUseCase: StartLedPreviewUseCase(
        repository: ledRecordRepository,
      ),
      stopLedPreviewUseCase: StopLedPreviewUseCase(
        repository: ledRecordRepository,
      ),
      startLedRecordUseCase: StartLedRecordUseCase(repository: ledRepository),
      initLedRecordUseCase: InitLedRecordUseCase(
        ledRecordRepository: ledRecordRepository,
        ledRepository: ledRepository,
      ),
      addSceneUseCase: AddSceneUseCase(
        ledRepository: ledRepository,
        sceneRepository: SceneRepositoryImpl(),
      ),
      updateSceneUseCase: UpdateSceneUseCase(
        ledRepository: ledRepository,
        sceneRepository: SceneRepositoryImpl(),
      ),
      deleteSceneUseCase: DeleteSceneUseCase(
        ledRepository: ledRepository,
        sceneRepository: SceneRepositoryImpl(),
      ),
      enterDimmingModeUseCase: EnterDimmingModeUseCase(
        bleAdapter: bleAdapter,
        commandBuilder: const LedCommandBuilder(),
      ),
      exitDimmingModeUseCase: ExitDimmingModeUseCase(
        bleAdapter: bleAdapter,
        commandBuilder: const LedCommandBuilder(),
      ),
      deviceConnectionCoordinator: DeviceConnectionCoordinator(
        connectionStream: platformTransportWriter.connectionStateStream,
        initializeDeviceUseCase: initializeDeviceUseCase,
        deviceRepository: deviceRepository,
      ),
    );
  }
}
