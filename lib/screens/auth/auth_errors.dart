import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../localization/language_scope.dart';

/// Turns a Supabase auth failure into a short message in the app language.
String authErrorMessage(BuildContext context, Object error) {
  if (error is AuthException) {
    final code = error.code ?? '';
    final message = error.message.toLowerCase();

    if (code == 'invalid_credentials' ||
        message.contains('invalid login credentials')) {
      return context.tr('auth_err_invalid_credentials');
    }
    if (code == 'email_not_confirmed' ||
        message.contains('email not confirmed')) {
      return context.tr('auth_err_email_not_confirmed');
    }
    if (code == 'user_already_exists' ||
        message.contains('already registered')) {
      return context.tr('auth_err_user_exists');
    }
    if (code == 'weak_password' || message.contains('password')) {
      return context.tr('auth_err_password_short');
    }
    if (code == 'validation_failed' && message.contains('email')) {
      return context.tr('auth_err_email_invalid');
    }
    return error.message;
  }
  return context.tr('auth_err_generic');
}

final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(BuildContext context, String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return context.tr('auth_err_email_required');
  if (!_emailPattern.hasMatch(email)) {
    return context.tr('auth_err_email_invalid');
  }
  return null;
}

String? validatePassword(BuildContext context, String? value) {
  final password = value ?? '';
  if (password.isEmpty) return context.tr('auth_err_password_required');
  if (password.length < 6) return context.tr('auth_err_password_short');
  return null;
}
