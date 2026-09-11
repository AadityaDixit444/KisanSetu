import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LotService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createLot({
    required String crop,
    required double quantity,
    required double askingPrice,
    required String location,
    required String quality,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    debugPrint('LotService.createLot - Auth user ID: ${user.id}');

    try {
      final insertedRow = await _supabase
          .from('lots')
          .insert({
            'farmer_id': user.id,
            'crop': crop,
            'quantity': quantity,
            'asking_price': askingPrice,
            'location': location,
            'quality': quality,
            'status': 'active',
          })
          .select()
          .single();

      debugPrint('LotService.createLot - Inserted row: $insertedRow');
    } on PostgrestException catch (e) {
      debugPrint(
        'LotService.createLot - PostgrestException: message=${e.message}, code=${e.code}, details=${e.details}, hint=${e.hint}',
      );
      rethrow;
    } catch (e) {
      debugPrint('LotService.createLot - Unexpected error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getFarmerLots() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    final response = await _supabase
        .from('lots')
        .select()
        .eq('farmer_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getActiveLots() async {
    final response = await _supabase
        .from('lots')
        .select()
        .eq('status', 'active')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}