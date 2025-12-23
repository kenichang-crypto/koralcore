library;

import '../../infrastructure/ble/ble_adapter.dart';
import '../../infrastructure/ble/ble_adapter_impl.dart';
import '../../infrastructure/ble/doser/ble_today_totals_data_source.dart';
import '../../infrastructure/ble/doser/today_totals_data_source.dart';
import '../../infrastructure/ble/platform_channels/ble_platform_transport_writer.dart';
import '../../infrastructure/ble/schedule/led/led_schedule_command_builder.dart';
import '../../infrastructure/ble/schedule/schedule_sender.dart';
import '../../infrastructure/ble/transport/ble_read_transport.dart';
import '../../infrastructure/ble/transport/ble_transport_log_buffer.dart';
import '../../infrastructure/repositories/device_repository_impl.dart';
import '../../infrastructure/repositories/doser_repository_impl.dart';
import '../../infrastructure/repositories/led_record_repository_impl.dart';
import '../../infrastructure/repositories/led_repository_impl.dart';
import '../../infrastructure/repositories/lighting_repository_impl.dart';
import '../../infrastructure/repositories/pump_head_repository_impl.dart';
import '../../infrastructure/repositories/sink_repository_impl.dart';
import '../../platform/contracts/device_repository.dart';
import '../../platform/contracts/dosing_port.dart';
import '../../platform/contracts/led_port.dart';
import '../../platform/contracts/led_record_repository.dart';
import '../../platform/contracts/led_repository.dart';
import '../../platform/contracts/pump_head_repository.dart';
import '../../platform/contracts/sink_repository.dart';
import '../common/app_error_mapper.dart';
import '../device/connect_device_usecase.dart';
import '../device/disconnect_device_usecase.dart';
import '../device/remove_device_usecase.dart';
import '../device/scan_devices_usecase.dart';
import '../doser/apply_schedule_usecase.dart';
import '../doser/read_calibration_history.dart';
import '../doser/read_dosing_schedule_summary_usecase.dart';
import '../doser/read_schedule.dart';
import '../doser/read_today_total.dart';
import '../doser/single_dose_immediate_usecase.dart';
import '../doser/single_dose_timed_usecase.dart';
import '../doser/schedule_capability_guard.dart';
import '../doser/schedule_result_mapper.dart';
import '../doser/update_pump_head_settings.dart';
import '../led/apply_led_schedule_usecase.dart';
import '../led/apply_scene_usecase.dart';
import '../led/clear_led_records_usecase.dart';
import '../led/delete_led_record_usecase.dart';
import '../led/led_record_store.dart';
import '../led/led_schedule_capability_guard.dart';
import '../led/led_schedule_result_mapper.dart';
import '../led/led_schedule_store.dart';
import '../led/observe_led_record_state_usecase.dart';
import '../led/observe_led_state_usecase.dart';
import '../led/read_led_record_state_usecase.dart';
import '../led/read_led_schedule_summary_usecase.dart';
import '../led/read_led_schedules.dart';
import '../led/read_led_state_usecase.dart';
import '../led/read_led_scenes.dart';
import '../led/read_lighting_state.dart';
import '../led/refresh_led_record_state_usecase.dart';
import '../led/reset_led_state_usecase.dart';
import '../led/save_led_schedule_usecase.dart';
import '../led/set_channel_intensity.dart';
import '../led/start_led_preview_usecase.dart';
import '../led/stop_led_preview_usecase.dart';
import '../session/current_device_session.dart';

/// Root dependency graph for the UI layer.
class AppContext {
  final DeviceRepository deviceRepository;
  final LedRepository ledRepository;
  final LedRecordRepository ledRecordRepository;
  final PumpHeadRepository pumpHeadRepository;
  final SinkRepository sinkRepository;
  final CurrentDeviceSession currentDeviceSession;
  final BleAdapter bleAdapter;

  final ScanDevicesUseCase scanDevicesUseCase;
  final ConnectDeviceUseCase connectDeviceUseCase;
  final DisconnectDeviceUseCase disconnectDeviceUseCase;
  final RemoveDeviceUseCase removeDeviceUseCase;
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
  final UpdatePumpHeadSettingsUseCase updatePumpHeadSettingsUseCase;
  final SingleDoseImmediateUseCase singleDoseImmediateUseCase;
  final SingleDoseTimedUseCase singleDoseTimedUseCase;
  final ApplyScheduleUseCase applyScheduleUseCase;
  final ApplyLedScheduleUseCase applyLedScheduleUseCase;
  final ObserveLedStateUseCase observeLedStateUseCase;
  final ReadLedStateUseCase readLedStateUseCase;
  final ObserveLedRecordStateUseCase observeLedRecordStateUseCase;
  final ReadLedRecordStateUseCase readLedRecordStateUseCase;
  final RefreshLedRecordStateUseCase refreshLedRecordStateUseCase;
  final DeleteLedRecordUseCase deleteLedRecordUseCase;
  final ClearLedRecordsUseCase clearLedRecordsUseCase;
  final StartLedPreviewUseCase startLedPreviewUseCase;
  final StopLedPreviewUseCase stopLedPreviewUseCase;

  AppContext._({
    required this.deviceRepository,
    required this.ledRepository,
    required this.ledRecordRepository,
    required this.pumpHeadRepository,
    required this.sinkRepository,
    required this.currentDeviceSession,
    required this.bleAdapter,
    required this.scanDevicesUseCase,
    required this.connectDeviceUseCase,
    required this.disconnectDeviceUseCase,
    required this.removeDeviceUseCase,
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
  });

  factory AppContext.bootstrap() {
    final SinkRepository sinkRepository = SinkRepositoryImpl();
    final LedRepository ledRepository = LedRepositoryImpl();
    final LedRecordMemoryStore ledRecordMemoryStore = LedRecordMemoryStore();
    final LedRecordRepository ledRecordRepository = LedRecordRepositoryImpl(
      store: ledRecordMemoryStore,
    );
    final DeviceRepository deviceRepository = DeviceRepositoryImpl(
      sinkRepository: sinkRepository,
    );
    final PumpHeadRepository pumpHeadRepository = PumpHeadRepositoryImpl();
    const LedPort ledPort = LightingRepositoryImpl();
    final currentDeviceSession = CurrentDeviceSession();
    final BleTransportLogBuffer transportLogBuffer = BleTransportLogBuffer();
    final BlePlatformTransportWriter platformTransportWriter =
        BlePlatformTransportWriter();
    final BleAdapter bleAdapter = BleAdapterImpl(
      transportWriter: platformTransportWriter.write,
      observer: transportLogBuffer,
    );
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
    final LedScheduleMemoryStore ledScheduleMemoryStore =
        LedScheduleMemoryStore();
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

    return AppContext._(
      deviceRepository: deviceRepository,
      ledRepository: ledRepository,
      ledRecordRepository: ledRecordRepository,
      pumpHeadRepository: pumpHeadRepository,
      sinkRepository: sinkRepository,
      currentDeviceSession: currentDeviceSession,
      bleAdapter: bleAdapter,
      scanDevicesUseCase: ScanDevicesUseCase(
        deviceRepository: deviceRepository,
      ),
      connectDeviceUseCase: ConnectDeviceUseCase(
        deviceRepository: deviceRepository,
        currentDeviceSession: currentDeviceSession,
      ),
      disconnectDeviceUseCase: DisconnectDeviceUseCase(
        deviceRepository: deviceRepository,
        currentDeviceSession: currentDeviceSession,
        pumpHeadRepository: pumpHeadRepository,
        ledRepository: ledRepository,
      ),
      removeDeviceUseCase: RemoveDeviceUseCase(
        deviceRepository: deviceRepository,
        currentDeviceSession: currentDeviceSession,
      ),
      readScheduleUseCase: const ReadScheduleUseCase(),
      readTodayTotalUseCase: readTodayTotalUseCase,
      readDosingScheduleSummaryUseCase: ReadDosingScheduleSummaryUseCase(
        dosingPort: dosingPort,
        currentDeviceSession: currentDeviceSession,
      ),
      readCalibrationHistoryUseCase: const ReadCalibrationHistoryUseCase(),
      readLedScenesUseCase: const ReadLedScenesUseCase(),
      readLedScheduleUseCase: ReadLedScheduleUseCase(
        store: ledScheduleMemoryStore,
      ),
      readLedScheduleSummaryUseCase: ReadLedScheduleSummaryUseCase(
        ledPort: ledPort,
        currentDeviceSession: currentDeviceSession,
      ),
      saveLedScheduleUseCase: SaveLedScheduleUseCase(
        store: ledScheduleMemoryStore,
      ),
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
    );
  }
}
