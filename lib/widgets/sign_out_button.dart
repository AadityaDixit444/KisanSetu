import 'package:flutter/material.dart';

import '../localization/language_scope.dart';
import '../screens/auth/auth_gate.dart';

/// App-bar icon: confirms, signs out, returns to the intro screen.
class SignOutButton extends StatelessWidget {
  const SignOutButton({super.key});

  Future<void> _confirm(BuildContext context) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.tr('auth_sign_out_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(dialogContext.tr('common_cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(dialogContext.tr('auth_sign_out')),
          ),
        ],
      ),
    );

    if (shouldSignOut != true || !context.mounted) return;
    await AuthFlow.signOut(context);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout_rounded),
      tooltip: context.tr('auth_sign_out'),
      onPressed: () => _confirm(context),
    );
  }
}
