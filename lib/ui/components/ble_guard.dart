import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BleGuardBanner extends StatelessWidget {
  const BleGuardBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(child: Text(l10n.bleDisconnectedWarning)),
        ],
      ),
    );
  }
}

Future<void> showBleGuardDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(l10n.bleGuardDialogTitle),
        content: Text(l10n.bleGuardDialogMessage),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.bleGuardDialogButton),
          ),
        ],
      );
    },
  );
}
