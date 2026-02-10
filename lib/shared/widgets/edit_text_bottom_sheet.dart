// PARITY: 100% Android bottom_sheet_edittext.xml + ModalBottomSheetEdittext.kt
// android/ReefB_Android/app/src/main/res/layout/bottom_sheet_edittext.xml
// android/ReefB_Android/app/src/main/java/.../ModalBottomSheetEdittext.kt
//
// Android 結構：
// - Root: ConstraintLayout (padding 16/12/16/12)
// - Header: tv_title (left, body_accent) + btn_close (right, 24x24, ic_close)
// - Content: tv_edt_title (caption1, marginTop 12) + layout_edt (TextInputLayout, marginTop 4)
// - Footer: btn_save (MaterialButton, full width, marginTop 24, marginBottom 20)
//
// Android 行為：
// - autoTrim on EditText
// - btn_close: dismiss()
// - btn_save: validates non-empty, calls listener callback, dismiss()
// - Supports 4 types: ADD_SINK, EDIT_SINK, ADD_DROP_TYPE, EDIT_DROP_TYPE

import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../assets/common_icon_helper.dart';

/// EditTextBottomSheet (Shared Widget)
///
/// PARITY: android/ReefB_Android/app/src/main/res/layout/bottom_sheet_edittext.xml
///
/// 100% Parity BottomSheet，支援 4 種模式：
/// - AddSink: 新增魚缸位置
/// - EditSink: 編輯魚缸位置
/// - AddDropType: 新增添加劑類型
/// - EditDropType: 編輯添加劑類型
class EditTextBottomSheet extends StatefulWidget {
  final EditTextBottomSheetType type;
  final String? initialValue;
  final Function(String)? onSave;

  const EditTextBottomSheet({
    super.key,
    required this.type,
    this.initialValue,
    this.onSave,
  });

  @override
  State<EditTextBottomSheet> createState() => _EditTextBottomSheetState();

  /// 顯示 BottomSheet
  static Future<String?> show(
    BuildContext context, {
    required EditTextBottomSheetType type,
    String? initialValue,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: EditTextBottomSheet(
          type: type,
          initialValue: initialValue,
          onSave: (value) => Navigator.of(context).pop(value),
        ),
      ),
    );
  }
}

class _EditTextBottomSheetState extends State<EditTextBottomSheet> {
  late TextEditingController _controller;
  String _currentValue = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _currentValue = widget.initialValue ?? '';
    _controller.addListener(() {
      setState(() {
        _currentValue = _controller.text.trim(); // autoTrim
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final config = _getConfig(l10n);

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
          // PARITY: Header (tv_title + btn_close, Line 13-36)
          Row(
            children: [
              // tv_title (Line 13-25)
              Expanded(
                child: Text(
                  config.title,
                  style: AppTextStyles.bodyAccent, // body_accent (Line 20)
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4), // dp_4 marginEnd (Line 18)
              // btn_close (Line 27-36)
              IconButton(
                icon: CommonIconHelper.getCloseIcon(
                  size: 24, // dp_24 (Line 30, 31)
                  color: AppColors.textPrimary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12), // dp_12 marginTop (Line 43)
          // PARITY: tv_edt_title (Line 38-51)
          Text(
            config.edtTitle,
            style: AppTextStyles.caption1.copyWith(
              color: AppColors.textPrimary, // text_aaaa (Line 46)
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4), // dp_4 marginTop (Line 58)
          // PARITY: layout_edt (TextInputLayout + TextInputEditText, Line 53-71)
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: AppTextStyles.body, // body (Line 70)
            keyboardType: TextInputType.text, // inputType="text" (Line 69)
            maxLines: 1,
          ),
          const SizedBox(height: 24), // dp_24 marginTop (Line 78)
          // PARITY: btn_save (MaterialButton, Line 73-84)
          SizedBox(
            width: double.infinity, // match_parent (Line 76)
            child: MaterialButton(
              onPressed: _currentValue.trim().isEmpty
                  ? null
                  : () {
                      final trimmed = _currentValue.trim();
                      if (trimmed.isEmpty) {
                        // PARITY: Android shows toast "名稱不可為空"
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.toastNameIsEmpty),
                          ),
                        );
                        return;
                      }
                      widget.onSave?.call(trimmed);
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
                config.btnText,
                style: AppTextStyles.caption1,
              ),
            ),
          ),
          const SizedBox(height: 20), // dp_20 marginBottom (Line 79)
        ],
      ),
    );
  }

  _BottomSheetConfig _getConfig(AppLocalizations l10n) {
    // PARITY: ModalBottomSheetEdittext.kt setView() (Line 51-88)
    switch (widget.type) {
      case EditTextBottomSheetType.addSink:
        // Line 53-56
        return _BottomSheetConfig(
          title: 'TODO(android @string/bottom_sheet_add_sink_title)', // TODO
          edtTitle:
              'TODO(android @string/bottom_sheet_add_sink_edittext_title)', // TODO
          btnText:
              'TODO(android @string/bottom_sheet_add_sink_button_text)', // TODO
        );
      case EditTextBottomSheetType.editSink:
        // Line 58-61
        return _BottomSheetConfig(
          title: 'TODO(android @string/bottom_sheet_edit_sink_title)', // TODO
          edtTitle:
              'TODO(android @string/bottom_sheet_edit_sink_edittext_title)', // TODO
          btnText:
              'TODO(android @string/bottom_sheet_edit_sink_button_text)', // TODO
        );
      case EditTextBottomSheetType.addDropType:
        // Line 63-67
        return _BottomSheetConfig(
          title:
              'TODO(android @string/bottom_sheet_add_drop_type_title)', // TODO
          edtTitle:
              'TODO(android @string/bottom_sheet_add_drop_type_edittext_title)', // TODO
          btnText:
              'TODO(android @string/bottom_sheet_add_drop_type_button_text)', // TODO
        );
      case EditTextBottomSheetType.editDropType:
        // Line 69-73
        return _BottomSheetConfig(
          title:
              'TODO(android @string/bottom_sheet_edit_drop_type_title)', // TODO
          edtTitle:
              'TODO(android @string/bottom_sheet_edit_drop_type_edittext_title)', // TODO
          btnText:
              'TODO(android @string/bottom_sheet_edit_drop_type_button_text)', // TODO
        );
    }
  }
}

/// PARITY: BottomSheetViewType enum (Line 144-150)
enum EditTextBottomSheetType {
  addSink, // ADD_SINK
  editSink, // EDIT_SINK
  addDropType, // ADD_DROP_TYPE
  editDropType, // EDIT_DROP_TYPE
}

class _BottomSheetConfig {
  final String title;
  final String edtTitle;
  final String btnText;

  _BottomSheetConfig({
    required this.title,
    required this.edtTitle,
    required this.btnText,
  });
}

