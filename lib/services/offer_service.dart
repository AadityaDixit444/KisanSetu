import 'package:supabase_flutter/supabase_flutter.dart';

class OfferService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> createOffer({
    required String lotId,
    required double offerPrice,
    required double quantity,
    String? demandId,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    String buyerId = user.id;

    if (demandId != null) {
      final lotResponse = await _client
          .from('lots')
          .select('farmer_id')
          .eq('id', lotId)
          .maybeSingle();

      if (lotResponse == null || lotResponse['farmer_id']?.toString() != user.id) {
        throw Exception('You are not authorized to offer this lot.');
      }

      final demandResponse = await _client
          .from('demands')
          .select('buyer_id, status')
          .eq('id', demandId)
          .maybeSingle();

      if (demandResponse == null ||
          demandResponse['status']?.toString().toLowerCase().trim() != 'active') {
        throw Exception('This buyer demand is no longer active.');
      }

      buyerId = demandResponse['buyer_id'].toString();
    }

    final insertData = <String, dynamic>{
      'lot_id': lotId,
      'buyer_id': buyerId,
      'offer_price': offerPrice,
      'quantity': quantity,
      'status': 'pending',
    };

    if (demandId != null) {
      insertData['demand_id'] = demandId;
    }

    await _client.from('offers').insert(insertData);
  }

  Future<List<Map<String, dynamic>>> getMyOffers() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    final response = await _client
        .from('offers')
        .select('''
          *,
          lots (
            crop,
            quantity,
            quality,
            asking_price,
            location,
            status
          )
        ''')
        .eq('buyer_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getOffersForFarmerLots() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
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
          demand_id,
          created_at,
          lots!inner (
            id,
            farmer_id,
            crop,
            quantity,
            quality,
            asking_price,
            location,
            status
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
      throw Exception('User is not authenticated.');
    }

    await _client
        .from('offers')
        .update({'status': 'accepted'})
        .eq('id', offerId);
  }

  Future<void> declineOffer({required String offerId}) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
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
    throw Exception('User is not authenticated.');
  }

  final offer = await _client
      .from('offers')
      .select('''
        id,
        lot_id,
        buyer_id,
        offer_price,
        quantity,
        lots (
          farmer_id,
          crop
        )
      ''')
      .eq('id', offerId)
      .single();

  final lotId = offer['lot_id'].toString();
  final buyerId = offer['buyer_id'].toString();
  final farmerId = offer['lots']['farmer_id'].toString();
  final crop = offer['lots']['crop'].toString();
  final agreedPrice = (offer['offer_price'] as num).toDouble();
  final quantity = (offer['quantity'] as num).toDouble();
  final totalAmount = agreedPrice * quantity;

  await _client.from('transactions').insert({
    'lot_id': lotId,
    'offer_id': offerId,
    'buyer_id': buyerId,
    'farmer_id': farmerId,
    'crop': crop,
    'agreed_price': agreedPrice,
    'quantity': quantity,
    'total_amount': totalAmount,
    'payment_status': 'escrow_pending',
    'dispatch_status': 'ready_for_dispatch',
  });

  await _client
      .from('lots')
      .update({'status': 'sold'})
      .eq('id', lotId);
}
}