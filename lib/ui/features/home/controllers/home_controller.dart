import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../application/device/device_snapshot.dart';
import '../../../../domain/sink/sink.dart';
import '../../../../platform/contracts/device_repository.dart';
import '../../../../platform/contracts/sink_repository.dart';
import '../../../features/device/controllers/device_list_controller.dart';

/// Controller for Home page sink selection and device filtering.
///
/// PARITY: Mirrors reef-b-app's HomeFragment.kt sink selection logic.
enum SinkSelectionType {
  allSinks, // 位置 0：所有 Sink
  favorite, // 位置 1：喜愛裝置
  specificSink, // 位置 2+：特定 Sink
  unassigned, // 最後位置：未分配裝置
}

class HomeController extends ChangeNotifier {
  final SinkRepository sinkRepository;
  final DeviceRepository deviceRepository;
  final DeviceListController deviceListController;

  HomeController({
    required this.sinkRepository,
    required this.deviceRepository,
    required this.deviceListController,
  }) {
    _initialize();
  }

  List<Sink> _sinks = [];
  List<DeviceSnapshot> _allDevices = [];
  SinkSelectionType _selectionType = SinkSelectionType.allSinks;
  String? _selectedSinkId;
  List<DeviceSnapshot> _filteredDevices = [];
  bool _useGridLayout = false; // false = ListView, true = GridView
  StreamSubscription<List<Sink>>? _sinkSubscription;
  int _selectedSinkIndex = 0;

  List<Sink> get sinks => List.unmodifiable(_sinks);
  SinkSelectionType get selectionType => _selectionType;
  String? get selectedSinkId => _selectedSinkId;
  List<DeviceSnapshot> get filteredDevices => List.unmodifiable(_filteredDevices);
  bool get useGridLayout => _useGridLayout;
  int get selectedSinkIndex => _selectedSinkIndex;

  /// Get spinner options list
  List<String> getSinkOptions(AppLocalizations l10n) {
    final options = <String>[
      l10n.homeSpinnerAllSink,
      l10n.homeSpinnerFavorite,
    ];
    // Add specific sinks
    for (final sink in _sinks) {
      if (sink.type == SinkType.custom) {
        options.add(sink.name);
      }
    }
    options.add(l10n.homeSpinnerUnassigned);
    return options;
  }

  void _initialize() {
    // Observe sinks
    _sinkSubscription = sinkRepository.observeSinks().listen((sinks) {
      _sinks = sinks;
      _updateFilteredDevices();
      notifyListeners();
    });

    // Observe devices from DeviceListController
    deviceListController.addListener(_onDevicesChanged);
    _onDevicesChanged();
  }

  void _onDevicesChanged() {
    _allDevices = deviceListController.savedDevices;
    _updateFilteredDevices();
    notifyListeners();
  }

  @override
  void dispose() {
    _sinkSubscription?.cancel();
    deviceListController.removeListener(_onDevicesChanged);
    super.dispose();
  }

  /// Select sink option by index (matching reef-b-app's Spinner position)
  void selectSinkOption(int index, AppLocalizations l10n) {
    final options = getSinkOptions(l10n);
    if (index < 0 || index >= options.length) return;

    _selectedSinkIndex = index;

    if (index == 0) {
      // 所有 Sink
      _selectionType = SinkSelectionType.allSinks;
      _selectedSinkId = null;
      _useGridLayout = false; // LinearLayoutManager
    } else if (index == 1) {
      // 喜愛裝置
      _selectionType = SinkSelectionType.favorite;
      _selectedSinkId = null;
      _useGridLayout = true; // GridLayoutManager(2)
    } else if (index == options.length - 1) {
      // 未分配裝置
      _selectionType = SinkSelectionType.unassigned;
      _selectedSinkId = null;
      _useGridLayout = true; // GridLayoutManager(2)
    } else {
      // 特定 Sink (index - 2)
      final sinkIndex = index - 2;
      final customSinks = _sinks.where((s) => s.type == SinkType.custom).toList();
      if (sinkIndex < customSinks.length) {
        final sink = customSinks[sinkIndex];
        _selectionType = SinkSelectionType.specificSink;
        _selectedSinkId = sink.id;
        _useGridLayout = true; // GridLayoutManager(2)
      }
    }

    _updateFilteredDevices();
    notifyListeners();
  }

  void _updateFilteredDevices() {
    switch (_selectionType) {
      case SinkSelectionType.allSinks:
        // PARITY: Show all sinks with their devices (SinkWithDevicesAdapter)
        // For now, show all devices (will be grouped by sink later)
        _filteredDevices = _allDevices.where((d) {
          // Only show devices that have a sinkId (assigned to a sink)
          // Need to check device's sinkId from repository
          return true; // TODO: Filter by sinkId
        }).toList();
        break;
      case SinkSelectionType.favorite:
        // PARITY: Show only favorite devices
        // TODO: Implement favorite filtering when DeviceSnapshot includes favorite field
        _filteredDevices = _allDevices; // Placeholder: show all for now
        break;
      case SinkSelectionType.specificSink:
        // PARITY: Show devices in specific sink
        // TODO: Implement sinkId filtering when DeviceSnapshot includes sinkId field
        _filteredDevices = _allDevices; // Placeholder: show all for now
        break;
      case SinkSelectionType.unassigned:
        // PARITY: Show unassigned devices (sinkId is null)
        // TODO: Implement unassigned filtering when DeviceSnapshot includes sinkId field
        _filteredDevices = _allDevices; // Placeholder: show all for now
        break;
    }
  }
}

