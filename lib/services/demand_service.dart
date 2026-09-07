import 'package:supabase_flutter/supabase_flutter.dart';

class DemandService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> createDemand({
    required String crop,
    required double quantity,
    required String quality,
    required double targetPrice,
    required String location,
    DateTime? requiredBy,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    final data = <String, dynamic>{
      'buyer_id': user.id,
      'crop': crop,
      'quantity': quantity,
      'quality': quality,
      'target_price': targetPrice,
      'location': location,
      'status': 'active',
    };

    if (requiredBy != null) {
      final yyyy = requiredBy.year.toString().padLeft(4, '0');
      final mm = requiredBy.month.toString().padLeft(2, '0');
      final dd = requiredBy.day.toString().padLeft(2, '0');
      data['required_by'] = '$yyyy-$mm-$dd';
    }

    await _client.from('demands').insert(data);
  }

  Future<List<Map<String, dynamic>>> getActiveDemands() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    final response = await _client
        .from('demands')
        .select('''
          id,
          buyer_id,
          crop,
          quantity,
          quality,
          target_price,
          location,
          required_by,
          status,
          created_at
        ''')
        .eq('status', 'active')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}