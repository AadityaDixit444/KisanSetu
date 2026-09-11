import 'package:supabase_flutter/supabase_flutter.dart';

class LogisticsService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, dynamic>?> getLogisticsForTransaction({
    required String transactionId,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found');
    }

    final transaction = await _client
        .from('transactions')
        .select('id, farmer_id')
        .eq('id', transactionId)
        .maybeSingle();

    if (transaction == null || transaction['farmer_id'] != user.id) {
      throw Exception('You are not authorized to view logistics for this transaction');
    }

    final logistics = await _client
        .from('logistics')
        .select()
        .eq('transaction_id', transactionId)
        .maybeSingle();

    return logistics;
  }

  Future<void> createLogistics({
    required String transactionId,
    required String vehicleType,
    required double transportCost,
    required String pickupLocation,
    required String deliveryLocation,
    required DateTime pickupDate,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found');
    }

    final transaction = await _client
        .from('transactions')
        .select('id, farmer_id')
        .eq('id', transactionId)
        .maybeSingle();

    if (transaction == null || transaction['farmer_id'] != user.id) {
      throw Exception('You are not authorized to arrange logistics for this transaction');
    }

    final existingLogistics = await _client
        .from('logistics')
        .select('id')
        .eq('transaction_id', transactionId)
        .maybeSingle();

    if (existingLogistics != null) {
      throw Exception('Logistics already arranged for this transaction');
    }

    final formattedPickupDate =
        '${pickupDate.year.toString().padLeft(4, '0')}-${pickupDate.month.toString().padLeft(2, '0')}-${pickupDate.day.toString().padLeft(2, '0')}';

    await _client.from('logistics').insert({
      'transaction_id': transactionId,
      'vehicle_type': vehicleType,
      'transport_cost': transportCost,
      'pickup_location': pickupLocation,
      'delivery_location': deliveryLocation,
      'status': 'arranged',
      'pickup_date': formattedPickupDate,
    });
  }
}