import 'package:supabase_flutter/supabase_flutter.dart';

class LotService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> createLot({
    required String crop,
    required double quantity,
    required String quality,
    required double askingPrice,
    required String location,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    await _client.from('lots').insert({
      'farmer_id': user.id,
      'crop': crop,
      'quantity': quantity,
      'quality': quality,
      'asking_price': askingPrice,
      'location': location,
    });
  }

  Future<List<Map<String, dynamic>>> getActiveLots() async {
    final response = await _client
        .from('lots')
        .select('id, farmer_id, crop, quantity, quality, asking_price, location, status, created_at')
        .eq('status', 'active')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}