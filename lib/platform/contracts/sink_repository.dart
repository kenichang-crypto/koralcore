library;

import '../../domain/sink/sink.dart';

abstract class SinkRepository {
  Stream<List<Sink>> observeSinks();

  List<Sink> getCurrentSinks();

  void upsertSink(Sink sink);

  void removeSink(SinkId sinkId);
}
