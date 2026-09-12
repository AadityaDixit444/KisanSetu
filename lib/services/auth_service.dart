import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Session? get currentSession => _client.auth.currentSession;

  bool get isSignedIn => currentSession != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Name given at sign-up (stored in Supabase user metadata), or null.
  String? get displayName {
    final name = currentUser?.userMetadata?['name'];
    if (name is String && name.trim().isNotEmpty) return name.trim();
    return null;
  }

  /// [displayName] that also returns null when Supabase was never
  /// initialised (widget tests), instead of throwing.
  static String? safeDisplayName() {
    try {
      return AuthService().displayName;
    } catch (_) {
      return null;
    }
  }

  Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signInAnonymously() async {
    return await _client.auth.signInAnonymously();
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
