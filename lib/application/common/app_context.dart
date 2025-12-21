library;

import '../../infrastructure/ble/ble_adapter.dart';
import '../../infrastructure/ble/ble_adapter_impl.dart';
import '../../infrastructure/ble/doser/ble_today_totals_data_source.dart';
import '../../infrastructure/ble/doser/today_totals_data_source.dart';
import '../../infrastructure/ble/platform_channels/ble_platform_transport_writer.dart';
import '../../infrastructure/ble/schedule/schedule_sender.dart';
import '../../infrastructure/ble/transport/ble_read_transport.dart';
import '../../infrastructure/ble/transport/ble_transport_log_buffer.dart';
import '../../infrastructure/repositories/device_repository_impl.dart';
import '../../infrastructure/repositories/doser_repository_impl.dart';
import '../../infrastructure/repositories/lighting_repository_impl.dart';
import '../../platform/contracts/device_repository.dart';
import '../../platform/contracts/dosing_port.dart';
import '../../platform/contracts/led_port.dart';
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
import '../led/read_led_scenes.dart';
import '../led/led_schedule_store.dart';
import '../led/lighting_state_store.dart';
import '../led/read_led_schedule_summary_usecase.dart';
import '../led/read_led_schedules.dart';
import '../led/read_lighting_state.dart';
import '../led/save_led_schedule_usecase.dart';
import '../led/set_channel_intensity.dart';
import '../session/current_device_session.dart';

/// Root dependency graph for the UI layer.
class AppContext {
  final DeviceRepository deviceRepository;
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
  final UpdatePumpHeadSettingsUseCase updatePumpHeadSettingsUseCase;
  final SingleDoseImmediateUseCase singleDoseImmediateUseCase;
  final SingleDoseTimedUseCase singleDoseTimedUseCase;
  final ApplyScheduleUseCase applyScheduleUseCase;

  AppContext._({
    required this.deviceRepository,
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
    required this.updatePumpHeadSettingsUseCase,
    required this.singleDoseImmediateUseCase,
    required this.singleDoseTimedUseCase,
    required this.applyScheduleUseCase,
  });

  factory AppContext.bootstrap() {
    final DeviceRepository deviceRepository = DeviceRepositoryImpl();
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
    final ScheduleSender scheduleSender = ScheduleSender(
      bleAdapter: bleAdapter,
    );
    final LightingStateMemoryStore lightingStateMemoryStore =
        LightingStateMemoryStore();
    final LedScheduleMemoryStore ledScheduleMemoryStore =
        LedScheduleMemoryStore();

    final ReadTodayTotalUseCase readTodayTotalUseCase = ReadTodayTotalUseCase(
      dosingPort: dosingPort,
      currentDeviceSession: currentDeviceSession,
    );

    return AppContext._(
      deviceRepository: deviceRepository,
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
        store: lightingStateMemoryStore,
      ),
      setChannelIntensityUseCase: SetChannelIntensityUseCase(
        store: lightingStateMemoryStore,
      ),
      updatePumpHeadSettingsUseCase: const UpdatePumpHeadSettingsUseCase(),
      singleDoseImmediateUseCase: SingleDoseImmediateUseCase(
        deviceRepository: deviceRepository,
        currentDeviceSession: currentDeviceSession,
        bleAdapter: bleAdapter,
        readTodayTotalUseCase: readTodayTotalUseCase,
      ),
      singleDoseTimedUseCase: SingleDoseTimedUseCase(
        deviceRepository: deviceRepository,
        currentDeviceSession: currentDeviceSession,
        bleAdapter: bleAdapter,
      ),
      applyScheduleUseCase: ApplyScheduleUseCase(
        deviceRepository: deviceRepository,
        scheduleCapabilityGuard: scheduleCapabilityGuard,
        scheduleResultMapper: scheduleResultMapper,
        currentDeviceSession: currentDeviceSession,
        scheduleSender: scheduleSender,
      ),
    );
  }
}
