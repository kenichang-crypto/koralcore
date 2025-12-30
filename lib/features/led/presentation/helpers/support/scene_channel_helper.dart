import '../../../../../l10n/app_localizations.dart';
import '../../models/led_scene_summary.dart';

class SceneChannelStat {
  const SceneChannelStat({
    required this.key,
    required this.label,
    required this.value,
  });

  final String key;
  final String label;
  final int value;
}

List<SceneChannelStat> buildSceneChannelStats(
  LedSceneSummary scene,
  AppLocalizations l10n,
) {
  final Map<String, int> levels = scene.channelLevels;
  final List<SceneChannelStat> stats = <SceneChannelStat>[];
  for (final String key in _channelOrder) {
    int? value = levels[key];
    if (value == null && key == 'moonLight') {
      value = levels['moon'];
    }
    if (value == null) {
      continue;
    }
    stats.add(
      SceneChannelStat(
        key: key,
        label: _channelLabel(key, l10n),
        value: value.clamp(0, 100),
      ),
    );
  }
  return stats;
}

const List<String> _channelOrder = <String>[
  'coldWhite',
  'royalBlue',
  'blue',
  'red',
  'green',
  'purple',
  'uv',
  'warmWhite',
  'moonLight',
];

String _channelLabel(String key, AppLocalizations l10n) {
  switch (key) {
    case 'coldWhite':
      return l10n.ledScheduleEditChannelWhite;
    case 'royalBlue':
      return l10n.ledScheduleEditChannelBlue;
    case 'blue':
      return l10n.ledChannelBlue;
    case 'red':
      return l10n.ledChannelRed;
    case 'green':
      return l10n.ledChannelGreen;
    case 'purple':
      return l10n.ledChannelPurple;
    case 'uv':
      return l10n.ledChannelUv;
    case 'warmWhite':
      return l10n.ledChannelWarmWhite;
    case 'moonLight':
      return l10n.ledChannelMoon;
    default:
      return key;
  }
}
