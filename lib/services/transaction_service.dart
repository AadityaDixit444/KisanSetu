import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getFarmerTransactions() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found');
    }

    final response = await _client
        .from('transactions')
        .select('''
          id,
          lot_id,
          buyer_id,
          farmer_id,
          agreed_price,
          quantity,
          total_amount,
          status,
          created_at,
          lots (
            crop,
            quality,
            location
          )
        ''')
        .eq('farmer_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}