import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Returns the current user's profile row, or null if none exists yet.
  Future<Map<String, dynamic>?> getMyProfile() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found');
    }

    return await _client
        .from('profiles')
        .select('id, name, role, phone, location')
        .eq('id', user.id)
        .maybeSingle();
  }

  /// The role ('farmer' / 'buyer') saved on the profile, or null if the user
  /// has not chosen one yet.
  Future<String?> getMyRole() async {
    final profile = await getMyProfile();
    final role = profile?['role']?.toString().trim().toLowerCase();
    if (role == 'farmer' || role == 'buyer') return role;
    return null;
  }

  Future<void> createProfileIfMissing({required String role}) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found');
    }

    final existing = await _client
        .from('profiles')
        .select('id, name')
        .eq('id', user.id)
        .maybeSingle();

    // Name entered at sign-up lives in the auth user metadata.
    final metadataName = user.userMetadata?['name'];
    final signUpName =
        metadataName is String && metadataName.trim().isNotEmpty
            ? metadataName.trim()
            : null;
    final defaultName = role == 'farmer' ? 'Farmer User' : 'Buyer User';

    if (existing != null) {
      final updates = <String, dynamic>{'role': role};
      final existingName = existing['name']?.toString().trim();
      // Backfill the real name if the row still has a placeholder.
      if (signUpName != null &&
          (existingName == null ||
              existingName.isEmpty ||
              existingName == 'Farmer User' ||
              existingName == 'Buyer User')) {
        updates['name'] = signUpName;
      }
      await _client.from('profiles').update(updates).eq('id', user.id);
    } else {
      await _client.from('profiles').insert({
        'id': user.id,
        'name': signUpName ?? defaultName,
        'role': role,
        'phone': null,
        'location': null,
      });
    }
  }
}
