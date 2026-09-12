import 'package:flutter/material.dart';

import '../../localization/language_scope.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../role_selection_screen.dart';
import 'auth_errors.dart';
import 'auth_gate.dart';
import 'auth_layout.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.signUpWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {'name': _nameController.text.trim()},
      );

      if (!mounted) return;

      // With "Confirm email" ON in the Supabase dashboard, sign-up returns a
      // user but no session until the link in the email is clicked.
      if (response.session == null) {
        await _showConfirmEmailDialog();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        return;
      }

      AuthFlow.goToScreen(context, const RoleSelectionScreen());
    } catch (error, stackTrace) {
      debugPrint('KisanSetu Sign-up error: $error');
      debugPrint('$stackTrace');

      if (!mounted) return;
      setState(() {
        _errorMessage = authErrorMessage(context, error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _showConfirmEmailDialog() {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.mark_email_read_outlined,
            color: AppColors.primary, size: 36),
        title: Text(dialogContext.tr('auth_check_email_title')),
        content: Text(dialogContext.tr('auth_check_email_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(dialogContext.tr('common_ok')),
          ),
        ],
      ),
    );
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthLayout(
      title: context.tr('auth_create_account_title'),
      subtitle: context.tr('auth_create_account_sub'),
      children: [
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                decoration: InputDecoration(
                  labelText: context.tr('auth_full_name'),
                  hintText: context.tr('auth_full_name_hint'),
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.tr('auth_err_name_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  labelText: context.tr('auth_email'),
                  hintText: context.tr('auth_email_hint'),
                  prefixIcon: const Icon(Icons.mail_outline_rounded),
                ),
                validator: (value) => validateEmail(context, value),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onFieldSubmitted: (_) => _signUp(),
                decoration: InputDecoration(
                  labelText: context.tr('auth_password'),
                  hintText: context.tr('auth_password_hint'),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? context.tr('auth_show_password')
                        : context.tr('auth_hide_password'),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) => validatePassword(context, value),
              ),
              const SizedBox(height: 22),
              AuthErrorBanner(message: _errorMessage),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _signUp,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : Text(context.tr('auth_sign_up_btn')),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      context.tr('auth_have_account'),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: _isSubmitting ? null : _goToLogin,
                    child: Text(context.tr('auth_sign_in_link')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
