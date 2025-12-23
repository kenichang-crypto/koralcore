library;

import 'dart:async';

import '../../domain/sink/sink.dart';
import '../../platform/contracts/sink_repository.dart';

class SinkRepositoryImpl implements SinkRepository {
  final List<Sink> _sinks = <Sink>[];
  final StreamController<List<Sink>> _controller =
      StreamController<List<Sink>>.broadcast();

  SinkRepositoryImpl({List<String>? initialDeviceIds}) {
    _sinks.add(Sink.defaultSink(initialDeviceIds ?? const []));
    _emit();
  }

  @override
  Stream<List<Sink>> observeSinks() => _controller.stream;

  @override
  List<Sink> getCurrentSinks() => List.unmodifiable(_sinks);

  @override
  void upsertSink(Sink sink) {
    final int index = _sinks.indexWhere((existing) => existing.id == sink.id);
    if (index == -1) {
      if (sink.type == SinkType.defaultSink) {
        _replaceDefaultSink(sink);
      } else {
        _sinks.add(sink);
      }
    } else {
      _sinks[index] = sink;
    }
    _emit();
  }

  @override
  void removeSink(SinkId sinkId) {
    final int index = _sinks.indexWhere((sink) => sink.id == sinkId);
    if (index == -1) {
      return;
    }
    if (_sinks[index].type == SinkType.defaultSink) {
      return;
    }
    _sinks.removeAt(index);
    _emit();
  }

  void _replaceDefaultSink(Sink sink) {
    final int index = _sinks.indexWhere(
      (existing) => existing.type == SinkType.defaultSink,
    );
    if (index == -1) {
      _sinks.add(sink);
    } else {
      _sinks[index] = sink;
    }
  }

  void _emit() {
    if (_controller.isClosed) {
      return;
    }
    _controller.add(List.unmodifiable(_sinks));
  }
}
