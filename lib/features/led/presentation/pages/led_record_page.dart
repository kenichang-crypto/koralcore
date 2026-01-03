import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../controllers/led_record_controller.dart';

/// LedRecordPage
///
/// Parity with reef-b-app LedRecordActivity (activity_led_record.xml)
/// Correction Mode: UI structure only, no behavior
class LedRecordPage extends StatelessWidget {
  const LedRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LedRecordView();
  }
}

class _LedRecordView extends StatelessWidget {
  const _LedRecordView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<LedRecordController>();

    return Stack(
      children: [
        Column(
          children: [
            // A. Toolbar (fixed) ↔ toolbar_two_action.xml
            _ToolbarTwoAction(l10n: l10n),

            // B–D. Content area (B+C fixed, D scrollable)
            Expanded(
              child: Container(
                color: AppColors.surfaceMuted, // bg_aaa
                child: Column(
                  children: [
                    // B. Record overview card (fixed, non-scrollable)
                    _RecordOverviewCard(l10n: l10n),

                    // C. Record list header (fixed, non-scrollable)
                    _RecordListHeader(l10n: l10n),

                    // D. Record list (only scrollable region)
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          // Record list items (placeholder)
                          // TODO(android @layout/adapter_led_record.xml)
                          _RecordTile(timeText: '07:00'),
                          _RecordTile(timeText: '12:00'),
                          _RecordTile(timeText: '18:00'),
                          _RecordTile(timeText: '22:00'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // E. Progress overlay ↔ progress.xml
        if (controller.isLoading) const _ProgressOverlay(),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// A. Toolbar (fixed) ↔ toolbar_two_action.xml
// ────────────────────────────────────────────────────────────────────────────

class _ToolbarTwoAction extends StatelessWidget {
  const _ToolbarTwoAction({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: Colors.white,
          height: 56,
          child: Row(
            children: [
              // Left: Back (icon button, no behavior)
              // TODO(android toolbar left button → uses back icon)
              IconButton(
                onPressed: null, // No behavior in Correction Mode
                icon: const Icon(Icons.arrow_back, size: 24),
              ),
              const Spacer(),
              // Center: Title (activity_led_record_title → @string/led_record)
              // TODO(android @string/led_record → "LED Record" / "LED 記錄")
              Text(
                l10n.ledRecordsTitle,
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              // Right: Setting (icon button, no behavior)
              // TODO(android toolbar right button → setting icon or action)
              IconButton(
                onPressed: null, // No behavior in Correction Mode
                icon: const Icon(Icons.settings, size: 24),
              ),
            ],
          ),
        ),
        // Divider (2dp ↔ toolbar_two_action.xml MaterialDivider)
        Container(height: 2, color: AppColors.divider),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// B. Record overview card (fixed) ↔ layout_chart
// ────────────────────────────────────────────────────────────────────────────

class _RecordOverviewCard extends StatelessWidget {
  const _RecordOverviewCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 16, // dp_16 marginStart
        top: 12, // dp_12 marginTop
        right: 16, // dp_16 marginEnd
      ),
      padding: const EdgeInsets.only(
        top: 16, // dp_16 paddingTop
        bottom: 24, // dp_24 paddingBottom
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), // background_white_radius
      ),
      child: Column(
        children: [
          // Clock display (tv_clock) ↔ headline, text_aaaa
          Text(
            '07:27', // Placeholder time
            style: AppTextStyles.headline.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8), // margin before chart
          // Chart placeholder (line_chart) ↔ no hardcoded size, flexible
          // TODO(android @layout/line_chart → 242dp in XML, but use flexible here)
          Padding(
            padding: const EdgeInsets.all(8), // dp_8 margin
            child: AspectRatio(
              aspectRatio: 16 / 9, // Flexible chart area
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    'Chart Placeholder',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16), // marginTop before buttons
          // Control buttons row (layout_btn) ↔ 5 ImageView buttons, 24x24dp each
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // btn_add (ic_add_black)
              // TODO(android @drawable/ic_add_black)
              _ControlButton(icon: Icons.add, onPressed: null),
              const SizedBox(width: 24), // marginStart + marginEnd = 24dp
              // btn_minus (ic_minus)
              // TODO(android @drawable/ic_minus)
              _ControlButton(icon: Icons.remove, onPressed: null),
              const SizedBox(width: 24),

              // btn_prev (ic_back)
              // TODO(android @drawable/ic_back)
              _ControlButton(icon: Icons.skip_previous, onPressed: null),
              const SizedBox(width: 24),

              // btn_next (ic_next)
              // TODO(android @drawable/ic_next)
              _ControlButton(icon: Icons.skip_next, onPressed: null),
              const SizedBox(width: 24),

              // btn_preview (ic_preview)
              // TODO(android @drawable/ic_preview)
              _ControlButton(icon: Icons.play_arrow, onPressed: null),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 24,
        minHeight: 24,
        maxWidth: 24,
        maxHeight: 24,
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// C. Record list header (fixed) ↔ tv_time_title + btn_add_time
// ────────────────────────────────────────────────────────────────────────────

class _RecordListHeader extends StatelessWidget {
  const _RecordListHeader({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16, // dp_16 marginStart
        top: 24, // dp_24 marginTop
        right: 16, // dp_16 marginEnd
      ),
      child: Row(
        children: [
          // Title: @string/time
          Expanded(
            child: Text(
              l10n.time,
              style: AppTextStyles.bodyAccent.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // btn_add_time (ic_add_btn, 24x24dp)
          // TODO(android @drawable/ic_add_btn)
          IconButton(
            onPressed: null, // No behavior in Correction Mode
            icon: const Icon(Icons.add_circle_outline, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// D. Record list items ↔ adapter_led_record.xml
// ────────────────────────────────────────────────────────────────────────────

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.timeText});

  final String timeText;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // bg_aaaa
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: null, // No behavior in Correction Mode
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16, // dp_16 paddingStart
              top: 12, // dp_12 paddingTop
              right: 16, // dp_16 paddingEnd
              bottom: 12, // dp_12 paddingBottom
            ),
            child: Row(
              children: [
                // Time text (tv_time) ↔ body, text_aaaa
                Expanded(
                  child: Text(
                    timeText,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8), // marginStart: dp_8
                // More icon (img_next → ic_more_enable, 24x24dp)
                // TODO(android @drawable/ic_more_enable)
                const Icon(
                  Icons.more_horiz,
                  size: 24,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// E. Progress overlay ↔ progress.xml
// ────────────────────────────────────────────────────────────────────────────

class _ProgressOverlay extends StatelessWidget {
  const _ProgressOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
