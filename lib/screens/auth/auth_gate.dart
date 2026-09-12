import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../theme/app_colors.dart';
import '../buyer/buyer_dashboard.dart';
import '../farmer_dashboard.dart';
import '../role_selection_screen.dart';
import 'intro_screen.dart';

/// Decides which screen the app opens on:
///
/// - no session            → [IntroScreen]
/// - session, no role yet  → [RoleSelectionScreen]
/// - session + role        → farmer / buyer dashboard
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<Widget> _startScreen = AuthFlow.resolveStartScreen();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _startScreen,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _SplashScreen();
        }
        return snapshot.data ?? const IntroScreen();
      },
    );
  }
}

/// Navigation helpers shared by the login / sign-up / role / logout paths.
abstract final class AuthFlow {
  static Future<Widget> resolveStartScreen() async {
    try {
      if (!AuthService().isSignedIn) return const IntroScreen();
      return await homeScreenForCurrentUser();
    } catch (error) {
      // Supabase not initialised (tests) or profile fetch failed.
      debugPrint('KisanSetu AuthGate: $error');
      return const IntroScreen();
    }
  }

  /// Dashboard for the signed-in user's role, or the role picker if the
  /// profile has no role yet.
  static Future<Widget> homeScreenForCurrentUser() async {
    final role = await ProfileService().getMyRole();
    switch (role) {
      case 'farmer':
        return const FarmerDashboard();
      case 'buyer':
        return const BuyerDashboard();
      default:
        return const RoleSelectionScreen();
    }
  }

  /// Call after a successful sign-in / sign-up. Clears the auth screens off
  /// the stack so Back does not return to the login form.
  static Future<void> goHome(BuildContext context) async {
    final home = await homeScreenForCurrentUser();
    if (!context.mounted) return;
    goToScreen(context, home);
  }

  static void goToScreen(BuildContext context, Widget screen) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  /// Signs out and returns to the intro screen.
  static Future<void> signOut(BuildContext context) async {
    await AuthService().signOut();
    if (!context.mounted) return;
    goToScreen(context, const IntroScreen());
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
