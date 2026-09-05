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

  Future<void> acceptOffer({required String offerId}) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found');
    }

    await _client
        .from('offers')
        .update({'status': 'accepted'})
        .eq('id', offerId);
  }

  Future<void> declineOffer({required String offerId}) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found');
    }

    await _client
        .from('offers')
        .update({'status': 'rejected'})
        .eq('id', offerId);
  }

  Future<void> createTransactionFromOffer({
    required String offerId,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found');
    }

    final offer = await _client
        .from('offers')
        .select('''
          lot_id,
          buyer_id,
          offer_price,
          quantity,
          lots (
            farmer_id
          )
        ''')
        .eq('id', offerId)
        .single();

    final lot = offer['lots'] as Map<String, dynamic>?;
    final farmerId = lot?['farmer_id']?.toString();

    if (farmerId == null || farmerId != user.id) {
      throw Exception('You are not authorized to create this transaction');
    }

    final offerPrice = (offer['offer_price'] as num).toDouble();
    final quantity = (offer['quantity'] as num).toDouble();
    final totalAmount = offerPrice * quantity;

    await _client.from('transactions').insert({
      'lot_id': offer['lot_id'],
      'buyer_id': offer['buyer_id'],
      'farmer_id': farmerId,
      'agreed_price': offerPrice,
      'quantity': quantity,
      'total_amount': totalAmount,
      'status': 'confirmed',
    });
  }
}