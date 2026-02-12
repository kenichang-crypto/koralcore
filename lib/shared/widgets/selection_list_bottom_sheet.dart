// PARITY: 100% Android bottom_sheet_recyclerview.xml + ModalBottomSheetRecyclerView.kt
// android/ReefB_Android/app/src/main/res/layout/bottom_sheet_recyclerview.xml
// android/ReefB_Android/app/src/main/java/.../ModalBottomSheetRecyclerView.kt
//
// Android 結構：
// - Root: ConstraintLayout (padding 16/12/16/12)
// - Header: tv_title (left, body_accent, "choose_group") + btn_close (right, 24x24, ic_close)
// - Content: rv_group (RecyclerView, marginTop 12)
// - Footer: btn_confirm (MaterialButton, full width, "confirm", marginTop 16, marginBottom 20)
//
// Android 行為：
// - RecyclerView with GroupAdapter (radio selection)
// - btn_close: dismiss()
// - btn_confirm: returns selected item, dismiss()
// - Used for LED Group selection (A, B, C, D, E)

import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../assets/common_icon_helper.dart';

/// SelectionListBottomSheet (Shared Widget)
///
/// PARITY: android/ReefB_Android/app/src/main/res/layout/bottom_sheet_recyclerview.xml
///
/// 100% Parity BottomSheet，支援單選列表。
/// 主要用於 LED Group 選擇 (A, B, C, D, E)，但可泛用於其他單選場景。
class SelectionListBottomSheet<T> extends StatefulWidget {
  final String title;
  final List<SelectionItem<T>> items;
  final T? initialSelection;
  final Function(T)? onConfirm;

  const SelectionListBottomSheet({
    super.key,
    required this.title,
    required this.items,
    this.initialSelection,
    this.onConfirm,
  });

  @override
  State<SelectionListBottomSheet<T>> createState() =>
      _SelectionListBottomSheetState<T>();

  /// 顯示 BottomSheet
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required List<SelectionItem<T>> items,
    T? initialSelection,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectionListBottomSheet<T>(
        title: title,
        items: items,
        initialSelection: initialSelection,
        onConfirm: (value) => Navigator.of(context).pop(value),
      ),
    );
  }
}

class _SelectionListBottomSheetState<T>
    extends State<SelectionListBottomSheet<T>> {
  late T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.only(
        left: 16, // dp_16 paddingStart (Line 7)
        top: 12, // dp_12 paddingTop (Line 8)
        right: 16, // dp_16 paddingEnd (Line 9)
        bottom: 12, // dp_12 paddingBottom (Line 10)
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PARITY: Header (tv_title + btn_close, Line 12-35)
          Row(
            children: [
              // tv_title (Line 12-24)
              Expanded(
                child: Text(
                  widget.title, // text="@string/choose_group" (Line 19)
                  style: AppTextStyles.bodyAccent, // body_accent (Line 20)
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4), // dp_4 marginEnd (Line 17)
              // btn_close (Line 26-35)
              IconButton(
                icon: CommonIconHelper.getCloseIcon(
                  size: 24, // dp_24 (Line 29, 30)
                  color: AppColors.textPrimary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12), // dp_12 marginTop (Line 41)
          // PARITY: rv_group (RecyclerView, Line 37-48)
          // wrap_content height, overScrollMode="never"
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: ListView.builder(
              shrinkWrap: true, // wrap_content (Line 40)
              physics:
                  const ClampingScrollPhysics(), // overScrollMode="never" (Line 42)
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final isSelected = _selectedValue == item.value;

                // PARITY: adapter_choose_group.xml (radio selection)
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedValue = item.value;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        // Radio button
                        Radio<T>(
                          value: item.value,
                          groupValue: _selectedValue,
                          onChanged: (value) {
                            setState(() {
                              _selectedValue = value;
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        // Item text
                        Expanded(
                          child: Text(
                            item.label,
                            style: AppTextStyles.body.copyWith(
                              color: isSelected
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16), // dp_16 marginTop (Line 55)
          // PARITY: btn_confirm (MaterialButton, Line 50-61)
          SizedBox(
            width: double.infinity, // match_parent (Line 53)
            child: MaterialButton(
              onPressed: _selectedValue == null
                  ? null
                  : () {
                      widget.onConfirm?.call(_selectedValue as T);
                    },
              color: AppColors.primary,
              textColor: AppColors.onPrimary,
              disabledColor: AppColors.surfaceMuted,
              disabledTextColor: AppColors.textDisabled,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                AppLocalizations.of(context).actionConfirm,
                style: AppTextStyles.caption1,
              ),
            ),
          ),
          const SizedBox(height: 20), // dp_20 marginBottom (Line 56)
        ],
      ),
    );
  }
}

/// Selection Item 資料結構
class SelectionItem<T> {
  final T value;
  final String label;

  const SelectionItem({required this.value, required this.label});
}
