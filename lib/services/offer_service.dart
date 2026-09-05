import 'package:supabase_flutter/supabase_flutter.dart';

class OfferService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> createOffer({
    required String lotId,
    required double offerPrice,
    required double quantity,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found');
    }

    await _client.from('offers').insert({
      'lot_id': lotId,
      'buyer_id': user.id,
      'offer_price': offerPrice,
      'quantity': quantity,
      'status': 'pending',
    });
  }

  Future<List<Map<String, dynamic>>> getMyOffers() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found');
    }

    final response = await _client
        .from('offers')
        .select('''
          id,
          lot_id,
          offer_price,
          quantity,
          status,
          created_at,
          lots (
            crop,
            quantity,
            location,
            asking_price
          )
        ''')
        .eq('buyer_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getOffersForFarmerLots() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found');
    }

    final response = await _client
        .from('offers')
        .select('''
          id,
          lot_id,
          buyer_id,
          offer_price,
          quantity,
          status,
          created_at,
          lots!inner (
            crop,
            quantity,
            quality,
            asking_price,
            location,
            farmer_id
          ),
          profiles:buyer_id (
            name,
            location
          )
        ''')
        .eq('lots.farmer_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}