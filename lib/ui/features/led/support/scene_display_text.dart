import '../../../../l10n/app_localizations.dart';
import '../models/led_scene_summary.dart';

class LedSceneDisplayText {
  const LedSceneDisplayText._();

  static String name(LedSceneSummary scene, AppLocalizations l10n) {
    if (scene.isPreset && scene.presetCode != null) {
      return _presetName(scene.presetCode!, l10n);
    }
    return scene.name;
  }

  static String description(LedSceneSummary scene, AppLocalizations l10n) {
    if (scene.isPreset && scene.presetCode != null) {
      return _presetDescription(scene.presetCode!, l10n);
    }
    return scene.description;
  }

  static String _presetName(int code, AppLocalizations l10n) {
    final _PresetLabel? label = _presetLabels[code];
    if (label == null) {
      return _fallbackPresetName(code);
    }
    return _resolveLabel(label.nameEn, label.nameZhHant, l10n);
  }

  static String _presetDescription(int code, AppLocalizations l10n) {
    final _PresetLabel? label = _presetLabels[code];
    if (label == null) {
      return _fallbackPresetDescription(code);
    }
    return _resolveLabel(label.descriptionEn, label.descriptionZhHant, l10n);
  }

  static String _resolveLabel(
    String english,
    String? zhHant,
    AppLocalizations l10n,
  ) {
    final String locale = l10n.localeName.toLowerCase();
    if (locale.contains('hant') && zhHant != null) {
      return zhHant;
    }
    return english;
  }

  static String _fallbackPresetName(int code) => 'Preset ${code.toString()}';

  static String _fallbackPresetDescription(int code) {
    switch (code) {
      case 0x00:
        return 'Turns every channel off.';
      case 0x01:
        return 'Sets all channels to 30% output.';
      case 0x02:
        return 'Sets all channels to 60% output.';
      case 0x03:
        return 'Drives every channel at full power.';
      case 0x04:
        return 'Low glow for nighttime viewing.';
      case 0x05:
        return 'Dynamic lightning-style flashes.';
    }
    return 'Reef B preset scene.';
  }
}

class _PresetLabel {
  const _PresetLabel({
    required this.nameEn,
    required this.descriptionEn,
    this.nameZhHant,
    this.descriptionZhHant,
  });

  final String nameEn;
  final String descriptionEn;
  final String? nameZhHant;
  final String? descriptionZhHant;
}

const Map<int, _PresetLabel> _presetLabels = <int, _PresetLabel>{
  0x00: _PresetLabel(
    nameEn: 'All off',
    descriptionEn: 'Turns every channel off.',
    nameZhHant: '全關',
    descriptionZhHant: '關閉所有燈路。',
  ),
  0x01: _PresetLabel(
    nameEn: '30% intensity',
    descriptionEn: 'Sets all channels to 30% output.',
    nameZhHant: '30% 輸出',
    descriptionZhHant: '所有燈路輸出 30%。',
  ),
  0x02: _PresetLabel(
    nameEn: '60% intensity',
    descriptionEn: 'Sets all channels to 60% output.',
    nameZhHant: '60% 輸出',
    descriptionZhHant: '所有燈路輸出 60%。',
  ),
  0x03: _PresetLabel(
    nameEn: '100% intensity',
    descriptionEn: 'Drives every channel at full power.',
    nameZhHant: '100% 輸出',
    descriptionZhHant: '所有燈路輸出 100%。',
  ),
  0x04: _PresetLabel(
    nameEn: 'Moonlight',
    descriptionEn: 'Low glow for nighttime viewing.',
    nameZhHant: '月光模式',
    descriptionZhHant: '柔和月光，適合夜間觀賞。',
  ),
  0x05: _PresetLabel(
    nameEn: 'Thunderstorm',
    descriptionEn: 'Dynamic lightning-style flashes.',
    nameZhHant: '雷雨模式',
    descriptionZhHant: '模擬雷雨閃電的動態效果。',
  ),
};
