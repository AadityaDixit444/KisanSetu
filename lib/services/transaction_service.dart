import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> acceptOfferAndCreateTransaction({
    required String offerId,
    required String lotId,
    required String buyerId,
    required String crop,
    required double quantity,
    required double agreedPrice,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    final existingTx = await _supabase
        .from('transactions')
        .select()
        .eq('offer_id', offerId)
        .maybeSingle();

    if (existingTx != null) {
      return Map<String, dynamic>.from(existingTx);
    }

    final double totalAmount = quantity * agreedPrice;

    debugPrint('TransactionService.acceptOfferAndCreateTransaction - Offer: $offerId, Lot: $lotId');

    try {
      final transactionRecord = await _supabase
          .from('transactions')
          .insert({
            'lot_id': lotId,
            'offer_id': offerId,
            'farmer_id': user.id,
            'buyer_id': buyerId,
            'crop': crop,
            'quantity': quantity,
            'agreed_price': agreedPrice,
            'total_amount': totalAmount,
            'payment_status': 'escrow_pending',
            'dispatch_status': 'ready_for_dispatch',
          })
          .select()
          .single();

      await _supabase
          .from('offers')
          .update({'status': 'accepted'})
          .eq('id', offerId);

      await _supabase
          .from('offers')
          .update({'status': 'rejected'})
          .eq('lot_id', lotId)
          .neq('id', offerId)
          .eq('status', 'pending');

      await _supabase
          .from('lots')
          .update({'status': 'sold'})
          .eq('id', lotId);

      return Map<String, dynamic>.from(transactionRecord);
    } on PostgrestException catch (e) {
      debugPrint('TransactionService.acceptOfferAndCreateTransaction - PostgrestException: ${e.message}, code: ${e.code}');
      rethrow;
    } catch (e) {
      debugPrint('TransactionService.acceptOfferAndCreateTransaction - Unexpected error: $e');
      rethrow;
    }
  }

  Future<void> rejectOffer(String offerId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    try {
      await _supabase
          .from('offers')
          .update({'status': 'rejected'})
          .eq('id', offerId);
    } on PostgrestException catch (e) {
      debugPrint('TransactionService.rejectOffer - PostgrestException: ${e.message}');
      rethrow;
    }
  }

  Future<void> updateDispatchStatus({
    required String transactionId,
    required String newStatus,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    const validStatuses = [
      'ready_for_dispatch',
      'pickup_scheduled',
      'in_transit',
      'delivered',
    ];

    if (!validStatuses.contains(newStatus)) {
      throw Exception('Invalid dispatch status: $newStatus');
    }

    try {
      await _supabase
          .from('transactions')
          .update({'dispatch_status': newStatus})
          .eq('id', transactionId)
          .eq('farmer_id', user.id);
    } on PostgrestException catch (e) {
      debugPrint('TransactionService.updateDispatchStatus - PostgrestException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('TransactionService.updateDispatchStatus - Unexpected error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getFarmerTransactions() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    debugPrint('getFarmerTransactions - Auth user ID: ${user.id}');

    try {
      final response = await _supabase
          .from('transactions')
          // profiles join: lets the UI show who the buyer is instead of an id
          .select('*, lots(*), profiles:buyer_id(name, location)')
          .eq('farmer_id', user.id)
          .order('created_at', ascending: false);

      final list = List<Map<String, dynamic>>.from(response);
      debugPrint('getFarmerTransactions - Rows returned: ${list.length}');
      return list;
    } on PostgrestException catch (e) {
      debugPrint('getFarmerTransactions - PostgrestException: ${e.message}, code: ${e.code}');
      rethrow;
    } catch (e) {
      debugPrint('getFarmerTransactions - Unexpected error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getTransactionById(String transactionId) async {
    final response = await _supabase
        .from('transactions')
        .select('*, lots(*)')
        .eq('id', transactionId)
        .maybeSingle();

    return response;
  }
}