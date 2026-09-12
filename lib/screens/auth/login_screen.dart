import 'package:flutter/material.dart';

import '../../localization/language_scope.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import 'auth_errors.dart';
import 'auth_gate.dart';
import 'auth_layout.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await _authService.signInWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      await AuthFlow.goHome(context);
    } catch (error, stackTrace) {
      debugPrint('KisanSetu Sign-in error: $error');
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

  void _goToSignUp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthLayout(
      title: context.tr('auth_sign_in_title'),
      subtitle: context.tr('auth_sign_in_sub'),
      children: [
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => _signIn(),
                decoration: InputDecoration(
                  labelText: context.tr('auth_password'),
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
                onPressed: _isSubmitting ? null : _signIn,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : Text(context.tr('auth_sign_in_btn')),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      context.tr('auth_no_account'),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: _isSubmitting ? null : _goToSignUp,
                    child: Text(context.tr('auth_sign_up_link')),
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
