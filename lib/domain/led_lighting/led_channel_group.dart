import 'led_channel.dart';

/// Logical bundling of LED channels recognized by firmware.
///
/// Each group defines both the transport byte (`id`) and the channel order
/// expected inside spectrum payloads.
enum LedChannelGroup {
  /// Full-spectrum fixtures that expose R/G/B/W/UV.
  fullSpectrum,
}

extension LedChannelGroupMetadata on LedChannelGroup {
  int get id {
    switch (this) {
      case LedChannelGroup.fullSpectrum:
        return 0x01;
    }
  }

  List<LedChannel> get channelOrder {
    switch (this) {
      case LedChannelGroup.fullSpectrum:
        return const <LedChannel>[
          LedChannel.red,
          LedChannel.green,
          LedChannel.blue,
          LedChannel.white,
          LedChannel.uv,
        ];
    }
  }
}
