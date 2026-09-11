import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> createProfileIfMissing({required String role}) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found');
    }

    final existing = await _client
        .from('profiles')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();

    final defaultName = role == 'farmer' ? 'Farmer User' : 'Buyer User';

    if (existing != null) {
      await _client.from('profiles').update({
        'role': role,
      }).eq('id', user.id);
    } else {
      await _client.from('profiles').insert({
        'id': user.id,
        'name': defaultName,
        'role': role,
        'phone': null,
        'location': null,
      });
    }
  }
}