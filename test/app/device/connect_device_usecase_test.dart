import 'package:flutter_test/flutter_test.dart';
import 'package:koralcore/app/common/app_error.dart';
import 'package:koralcore/app/common/app_error_code.dart';
import 'package:koralcore/app/device/connect_device_usecase.dart';
import 'package:koralcore/app/device/initialize_device_usecase.dart';
import 'package:koralcore/app/session/current_device_session.dart';
import 'package:koralcore/domain/device/capability_set.dart';
import 'package:koralcore/domain/device/device_context.dart';
import 'package:koralcore/domain/device/device_product.dart';
import 'package:koralcore/domain/device/firmware_version.dart';
import 'package:koralcore/platform/contracts/device_repository.dart';
import 'package:koralcore/platform/contracts/system_repository.dart';

// Mocks
class MockDeviceRepository implements DeviceRepository {
  final List<String> log = [];
  bool connectShouldThrow = false;

  @override
  Future<void> connect(String deviceId) async {
    log.add('connect($deviceId)');
    if (connectShouldThrow) {
      throw const AppError(
        code: AppErrorCode.transportError,
        message: 'Connect failed',
      );
    }
  }

  @override
  Future<void> updateDeviceState(String deviceId, String state) async {
    log.add('updateDeviceState($deviceId, $state)');
  }

  @override
  Future<void> setCurrentDevice(String deviceId) async {
    log.add('setCurrentDevice($deviceId)');
  }

  // Unused methods for this test
  @override
  Future<void> addDevice(
    String deviceId, {
    Map<String, dynamic>? metadata,
  }) async {}
  @override
  Future<void> addSavedDevice(Map<String, dynamic> record) async {}
  @override
  Future<List<Map<String, dynamic>>> getDevicesBySinkId(String sinkId) async =>
      [];
  @override
  Future<List<Map<String, dynamic>>> getDevicesBySinkIdAndGroup(
    String sinkId,
    String groupId,
  ) async => [];
  @override
  Future<List<Map<String, dynamic>>> getDropDevicesBySinkId(
    String sinkId,
  ) async => [];
  @override
  Future<void> disconnect(String deviceId) async {}
  @override
  Future<String?> getCurrentDevice() async => null;
  @override
  Future<String?> getDeviceState(String deviceId) async => null;
  @override
  Future<List<Map<String, dynamic>>> getSavedDevices() async => [];
  @override
  Future<List<Map<String, dynamic>>> scanDevices({Duration? timeout}) async =>
      [];
  @override
  Future<List<Map<String, dynamic>>> listSavedDevices() async => [];
  @override
  Future<void> removeSavedDevice(String deviceId) async {}
  @override
  Stream<List<Map<String, dynamic>>> observeDevices() => const Stream.empty();
  @override
  Future<void> toggleFavoriteDevice(String deviceId) async {}
  @override
  Future<bool> isDeviceFavorite(String deviceId) async => false;
  @override
  Future<Map<String, dynamic>?> getDevice(String deviceId) async => null;
  @override
  Stream<List<Map<String, dynamic>>> observeSavedDevices() =>
      const Stream.empty();
  @override
  Future<void> removeDevice(String deviceId) async {}
  @override
  Future<void> updateDeviceInDatabase(Map<String, dynamic> record) async {}
  @override
  Future<void> updateDeviceName(String deviceId, String name) async {}
  @override
  Future<void> updateDeviceSink(String deviceId, String? sinkId) async {}
  @override
  Future<void> saveFirmware(String deviceId, FirmwareVersion version) async {}
  @override
  Future<void> saveMetadata(
    String deviceId,
    Map<String, dynamic> metadata,
  ) async {}
}

class MockCurrentDeviceSession implements CurrentDeviceSession {
  @override
  void start(DeviceContext context) {}
  @override
  void clear() {}
  @override
  DeviceContext? get context => null;
  @override
  DeviceContext get requireContext => throw UnimplementedError();
  @override
  Stream<DeviceContext?> get stream => const Stream.empty();

  // Implement other required methods if any (none for this test usage)
  @override
  void addListener(void Function() listener) {}
  @override
  void dispose() {}
  @override
  bool get hasListeners => false;
  @override
  void notifyListeners() {}
  @override
  void removeListener(void Function() listener) {}

  // Other members might be needed depending on implementation details
  // but ConnectDeviceUseCase only calls start() (which we removed)
  // or InitializeDeviceUseCase calls it.
  // Since we mock InitializeDeviceUseCase, we might not need this much.
}

class MockInitializeDeviceUseCase implements InitializeDeviceUseCase {
  final List<String> log = [];
  bool executeShouldThrow = false;

  @override
  // Ignore constructor requirements by not calling super
  // But Dart requires super constructor call if we extend.
  // Since InitializeDeviceUseCase has required params, we need to pass dummies.
  // Or we can implement if it was an interface, but it's a class.
  // We'll just pass nulls casting to required types if possible, or create dummies.
  // Actually, mocking concrete classes is hard without mockito.
  // Let's rely on `implements` which works for classes in Dart (implicit interface).
  // But we need to implement ALL members.
  // Wait, `InitializeDeviceUseCase` is a class. `implements` works!
  // We just need to implement all public members.
  DeviceRepository get deviceRepository => throw UnimplementedError();
  SystemRepository get systemRepository => throw UnimplementedError();
  CurrentDeviceSession get currentDeviceSession => throw UnimplementedError();

  @override
  Future<DeviceContext> execute({required String deviceId}) async {
    log.add('execute($deviceId)');
    if (executeShouldThrow) {
      throw const AppError(
        code: AppErrorCode.unknownError,
        message: 'Init failed',
      );
    }
    return DeviceContext(
      deviceId: deviceId,
      product: DeviceProduct.ledController,
      firmware: const FirmwareVersion('1.0.0'),
      capabilities: const CapabilitySet.empty(),
    );
  }
}

void main() {
  group('ConnectDeviceUseCase', () {
    late ConnectDeviceUseCase useCase;
    late MockDeviceRepository deviceRepository;
    late MockInitializeDeviceUseCase initializeDeviceUseCase;
    late MockCurrentDeviceSession currentDeviceSession;

    setUp(() {
      deviceRepository = MockDeviceRepository();
      initializeDeviceUseCase = MockInitializeDeviceUseCase();
      currentDeviceSession = MockCurrentDeviceSession();
      useCase = ConnectDeviceUseCase(
        deviceRepository: deviceRepository,
        currentDeviceSession: currentDeviceSession,
        initializeDeviceUseCase: initializeDeviceUseCase,
      );
    });

    test('Success: connect -> set current -> initialize', () async {
      await useCase.execute(deviceId: 'test_device');

      expect(deviceRepository.log, [
        'updateDeviceState(test_device, connecting)',
        'connect(test_device)',
        'setCurrentDevice(test_device)',
        // 'connected' state is NO LONGER set by ConnectDeviceUseCase
      ]);
      expect(initializeDeviceUseCase.log, ['execute(test_device)']);
    });

    test('Failure: connect fails -> disconnected', () async {
      deviceRepository.connectShouldThrow = true;

      try {
        await useCase.execute(deviceId: 'test_device');
        fail('Should throw');
      } catch (e) {
        expect(e, isA<AppError>());
      }

      expect(deviceRepository.log, [
        'updateDeviceState(test_device, connecting)',
        'connect(test_device)',
        'updateDeviceState(test_device, disconnected)',
      ]);
      expect(initializeDeviceUseCase.log, isEmpty);
    });

    test('Failure: init fails -> disconnected', () async {
      initializeDeviceUseCase.executeShouldThrow = true;

      try {
        await useCase.execute(deviceId: 'test_device');
        fail('Should throw');
      } catch (e) {
        expect(e, isA<AppError>());
      }

      expect(deviceRepository.log, [
        'updateDeviceState(test_device, connecting)',
        'connect(test_device)',
        'setCurrentDevice(test_device)',
        'updateDeviceState(test_device, disconnected)',
      ]);
      expect(initializeDeviceUseCase.log, ['execute(test_device)']);
    });
  });
}
