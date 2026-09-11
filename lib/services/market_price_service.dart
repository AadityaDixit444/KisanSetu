import 'package:supabase_flutter/supabase_flutter.dart';

class MarketPriceService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getMarketPrices({
    String? market,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found');
    }

    var query = _client.from('market_prices').select('''
          id,
          crop,
          market,
          price,
          arrival_volume,
          demand_level,
          price_change,
          recorded_at
        ''');

    if (market != null && market.isNotEmpty) {
      query = query.eq('market', market);
    }

    final response = await query.order('recorded_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getLatestPrice({
    required String crop,
    required String market,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found');
    }

    final response = await _client
        .from('market_prices')
        .select('''
          id,
          crop,
          market,
          price,
          arrival_volume,
          demand_level,
          price_change,
          recorded_at
        ''')
        .eq('crop', crop)
        .eq('market', market)
        .order('recorded_at', ascending: false)
        .limit(1)
        .maybeSingle();

    return response;
  }

  Future<List<Map<String, dynamic>>> getPricesForCrop({
    required String crop,
    required String market,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found');
    }

    final response = await _client
        .from('market_prices')
        .select('''
          id,
          crop,
          market,
          price,
          arrival_volume,
          demand_level,
          price_change,
          recorded_at
        ''')
        .eq('crop', crop)
        .eq('market', market)
        .order('recorded_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}