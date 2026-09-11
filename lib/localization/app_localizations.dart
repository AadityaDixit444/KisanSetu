import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_language.dart';
import 'number_formatter.dart';

/// The core localization class providing key-based translation lookup,
/// argument interpolation, and strict English digit enforcement.
class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale) {
    _loadBuiltInStrings();
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Retrieve the [AppLocalizations] instance from the widget tree.
  static AppLocalizations of(BuildContext context) {
    final instance = Localizations.of<AppLocalizations>(context, AppLocalizations);
    return instance ?? AppLocalizations(const Locale('en'));
  }

  /// Built-in fallback dictionary for English strings.
  static const Map<String, String> _enStrings = {
    'app_name': 'KisanSetu',
    'app_tagline': 'Direct Agricultural Marketplace',
    'select_role_title': 'Choose how you want to continue:',
    'role_farmer_title': 'I am a Farmer',
    'role_farmer_desc': 'List produce, track live mandi rates, simulate holding returns, and connect with verified buyers.',
    'role_buyer_title': 'I am a Buyer',
    'role_buyer_desc': 'Source directly from farmers, post commodity demands, make bids, and track active purchases.',

    'language': 'Language',
    'lang_en': 'English',
    'lang_hi': 'हिन्दी',

    'greeting_morning': 'Good morning,',
    'greeting_afternoon': 'Good afternoon,',
    'greeting_evening': 'Good evening,',
    'role_farmer': 'Farmer',
    'role_buyer': 'Buyer',

    'notifications_title': 'Notifications',
    'notif_buyer_offer_title': 'New Buyer Offer',
    'notif_buyer_offer_desc': 'Kisan Agro Flour Mills offered ₹2,470/qtl for your Wheat lot.\n10 min ago',
    'notif_market_alert_title': 'Market Alert',
    'notif_market_alert_desc': 'Wheat prices increased by 3.4% today in Meerut.\n1 hour ago',
    'notif_offer_update_title': 'Offer Update',
    'notif_offer_update_desc': 'Your offer for Wheat 150 qtl was accepted.\n3 hours ago',
    'notif_logistics_title': 'Logistics Update',
    'notif_logistics_desc': 'Transport has been arranged for your Wheat shipment.\nYesterday',

    'market_overview': 'Market Overview',
    'live_apmc': 'Live APMC',
    'crop_wheat': 'Wheat',
    'crop_rice': 'Rice',
    'crop_mustard': 'Mustard',
    'price_trend_positive': '+3.4% today',
    'trade_momentum_high': '• High trade momentum',

    'ai_market_signal': 'AI Market Signal',
    'signal_sell_partially': 'SELL PARTIALLY',
    'signal_sell_now': 'SELL NOW',
    'signal_hold': 'HOLD',
    'ai_recommendation_wheat': 'Lock profits for 40% stock today. Remaining lot can gain from expected surge next week.',
    'net_realisable_breakdown': 'Net Realisable Price Breakdown',
    'net_price': 'Net Price',

    'actions_tools': 'Actions & Tools',
    'create_new_lot': 'Create New Lot',
    'create_new_lot_desc': 'List your crop and connect with buyers',
    'my_lots': 'My Lots',
    'my_lots_desc': 'View and manage your listed crops',
    'active_lots_summary': '2 Active Lots • 180 qtl',
    'active_lot_badge': 'Active Lot',
    'what_if_simulator': 'What-If Simulator',
    'what_if_simulator_desc': 'Test hold duration vs storage charges.',
    'smart_aggregation': 'Smart Aggregation',
    'smart_aggregation_desc': 'Combine your crop with nearby farmers for larger bulk lots',
    'intelligent_matching': 'Intelligent Buyer Matching',
    'intelligent_matching_desc': 'Find the best buyers for your crop based on price, demand and location',
    'top_buyer_opportunities': 'Top Buyer Opportunities',
    'view_all': 'View All',

    'browse_lots': 'Browse Lots',
    'post_demand': 'Post Demand',
    'my_purchases': 'My Purchases',
    'recommended_lots': 'Recommended Lots',
    'recent_transactions': 'Recent Transactions',
    'my_offers': 'My Offers',

    'good_quality': 'Good Quality',
    'premium_quality': 'Premium Quality',
    'distance_away': '{distance} km away',
    'quantity_qtl': '{quantity} qtl',
    'price_per_qtl': '₹{price}/qtl',

    'status_pending': 'Pending',
    'status_confirmed': 'Confirmed',
    'status_in_transit': 'In Transit',
    'status_delivered': 'Delivered',
    'status_payment_pending': 'Payment Pending',

    'mandi_rate_meerut': 'Meerut Mandi Rate',
    'trend_today_4_2': '+4.2% Today',
    'per_quintal_wheat': '/ quintal (Wheat)',
    'direct_bids_realization_desc': 'Direct aggregate bids currently yield ₹120-150/qtl higher realization.',
    'market_recommendation_title': 'Market Recommendation',
    'market_recommendation_desc': 'Get HOLD / SELL guidance based on live mandi conditions',
    'post_new_produce_lot_title': 'Post New Produce Lot',
    'post_new_produce_lot_desc': 'List harvested crop with quality, quantity & asking price',
    'my_active_lots_title': 'My Active Lots',
    'my_active_lots_desc': 'View listed crops, active lots & manage offers',
    'buyer_demand_board_title': 'Buyer Demand Board',
    'buyer_demand_board_desc': 'View active commodity requirements posted by buyers',
    'dispatches_deals_title': 'Dispatches & Deals',
    'dispatches_deals_desc': 'Track accepted deals, pickups & direct payments',
    'intelligent_matching_title': 'Intelligent Buyer Matching',
    'intelligent_matching_desc': 'Compare net realisable rates across institutional buyers',
    'buyer_demand_label': 'Buyer Demand',
    'compare_net_price': 'Compare Net Price',
    'delhi_ncr_distance': 'Delhi NCR • 65 km away',
    'wheat_demand_500': 'Wheat • Need 500 Quintals',
    'net_rate_2520': '₹2,520/qtl net',
    'noida_hub_distance': 'Noida Hub • 48 km away',
    'wheat_demand_200': 'Wheat • Need 200 Quintals',
    'net_rate_2490': '₹2,490/qtl net',

    'procurement_index': 'Procurement Index',
    'active_market': 'Active Market',
    'per_quintal_benchmark_wheat': '/ quintal benchmark (Wheat)',
    'direct_procurement_savings_desc': 'Direct procurement saves up to 8% on intermediary Mandi handling and commission charges.',
    'post_commodity_demand_title': 'Post Commodity Demand',
    'active_demands_badge': '{count} Active',
    'broadcast_demand_desc': 'Broadcast your required quantity, target price & delivery location',
    'browse_farmer_produce_lots': 'Browse Farmer Produce Lots',
    'my_submitted_offers_title': 'My Submitted Offers',
    'my_submitted_offers_desc': 'Track pending bids, accepted deals & farmer counter-proposals',
    'direct_farmer_opportunities': 'Direct Farmer Opportunities',
    'no_active_farmer_lots': 'No active farmer lots listed currently.',
    'volume_with_quality': 'Volume: {volume} • {quality}',
  };

  /// Built-in fallback dictionary for Hindi strings.
  /// All numbers (0-9) are strictly kept in English digits.
  static const Map<String, String> _hiStrings = {
    'app_name': 'किसानसेतु',
    'app_tagline': 'प्रत्यक्ष कृषि बाज़ार',
    'select_role_title': 'चुनें कि आप कैसे जारी रखना चाहते हैं:',
    'role_farmer_title': 'मैं एक किसान हूँ',
    'role_farmer_desc': 'उत्पाद सूचीबद्ध करें, लाइव मंडी दरें ट्रैक करें, होल्डिंग रिटर्न सिम्युलेट करें और सत्यापित खरीदारों से जुड़ें।',
    'role_buyer_title': 'मैं एक खरीदार हूँ',
    'role_buyer_desc': 'सीधे किसानों से खरीदें, कमोडिटी मांग पोस्ट करें, बोलियां लगाएं और सक्रिय खरीदारी ट्रैक करें।',

    'language': 'भाषा',
    'lang_en': 'English',
    'lang_hi': 'हिन्दी',

    'greeting_morning': 'सुप्रभात,',
    'greeting_afternoon': 'शुभ दोपहर,',
    'greeting_evening': 'शुभ संध्या,',
    'role_farmer': 'किसान',
    'role_buyer': 'खरीदार',

    'notifications_title': 'सूचनाएं',
    'notif_buyer_offer_title': 'नया खरीदार प्रस्ताव',
    'notif_buyer_offer_desc': 'किसान एग्रो फ्लोर मिल्स ने आपके गेहूं लॉट के लिए ₹2,470/क्विंटल की पेशकश की।\n10 मिनट पहले',
    'notif_market_alert_title': 'बाज़ार अलर्ट',
    'notif_market_alert_desc': 'मेरठ में आज गेहूं की कीमतों में 3.4% की वृद्धि हुई।\n1 घंटा पहले',
    'notif_offer_update_title': 'प्रस्ताव अपडेट',
    'notif_offer_update_desc': 'गेहूं 150 क्विंटल के लिए आपका प्रस्ताव स्वीकार कर लिया गया।\n3 घंटे पहले',
    'notif_logistics_title': 'लॉजिस्टिक्स अपडेट',
    'notif_logistics_desc': 'आपके गेहूं शिपमेंट के लिए परिवहन की व्यवस्था कर दी गई है।\nकल',

    'market_overview': 'बाज़ार अवलोकन',
    'live_apmc': 'लाइव APMC',
    'crop_wheat': 'गेहूं',
    'crop_rice': 'चावल',
    'crop_mustard': 'सरसों',
    'price_trend_positive': '+3.4% आज',
    'trade_momentum_high': '• उच्च व्यापार गति',

    'ai_market_signal': 'एआई बाज़ार संकेत',
    'signal_sell_partially': 'आंशिक बिक्री करें',
    'signal_sell_now': 'अभी बेचें',
    'signal_hold': 'रोक कर रखें',
    'ai_recommendation_wheat': 'आज 40% स्टॉक का लाभ सुरक्षित करें। शेष लॉट अगले सप्ताह संभावित वृद्धि से लाभान्वित हो सकता है।',
    'net_realisable_breakdown': 'शुद्ध प्राप्य मूल्य विवरण',
    'net_price': 'शुद्ध मूल्य',

    'actions_tools': 'कार्य और उपकरण',
    'create_new_lot': 'नया लॉट बनाएं',
    'create_new_lot_desc': 'अपनी फसल सूचीबद्ध करें और खरीदारों से जुड़ें',
    'my_lots': 'मेरे लॉट',
    'my_lots_desc': 'अपनी सूचीबद्ध फसलों को देखें और प्रबंधित करें',
    'active_lots_summary': '2 सक्रिय लॉट • 180 क्विंटल',
    'active_lot_badge': 'सक्रिय लॉट',
    'what_if_simulator': 'व्हाट-इफ सिम्युलेटर',
    'what_if_simulator_desc': 'होल्ड अवधि बनाम भंडारण शुल्क का परीक्षण करें।',
    'smart_aggregation': 'स्मार्ट एकत्रीकरण',
    'smart_aggregation_desc': 'बड़े थोक लॉट के लिए पास के किसानों के साथ अपनी फसल मिलाएं',
    'intelligent_matching': 'इंटेलिजेंट खरीदार मिलान',
    'intelligent_matching_desc': 'कीमत, मांग और स्थान के आधार पर अपनी फसल के लिए सर्वोत्तम खरीदार खोजें',
    'top_buyer_opportunities': 'शीर्ष खरीदार अवसर',
    'view_all': 'सभी देखें',

    'browse_lots': 'लॉट ब्राउज़ करें',
    'post_demand': 'मांग पोस्ट करें',
    'my_purchases': 'मेरी खरीदारियां',
    'recommended_lots': 'अनुशंसित लॉट',
    'recent_transactions': 'हाल के लेन-देन',
    'my_offers': 'मेरे प्रस्ताव',

    'good_quality': 'अच्छी गुणवत्ता',
    'premium_quality': 'प्रीमियम गुणवत्ता',
    'distance_away': '{distance} किमी दूर',
    'quantity_qtl': '{quantity} क्विंटल',
    'price_per_qtl': '₹{price}/क्विंटल',

    'status_pending': 'लंबित',
    'status_confirmed': 'पुष्टि की गई',
    'status_in_transit': 'रास्ते में',
    'status_delivered': 'वितरित',
    'status_payment_pending': 'भुगतान लंबित',

    'mandi_rate_meerut': 'मेरठ मंडी दर',
    'trend_today_4_2': '+4.2% आज',
    'per_quintal_wheat': '/ क्विंटल (गेहूं)',
    'direct_bids_realization_desc': 'प्रत्यक्ष संयुक्त बोलियों से वर्तमान में ₹120-150/क्विंटल अधिक प्राप्ति होती है।',
    'market_recommendation_title': 'बाज़ार अनुशंसा',
    'market_recommendation_desc': 'लाइव मंडी स्थितियों के आधार पर रोकें / बेचें मार्गदर्शन प्राप्त करें',
    'post_new_produce_lot_title': 'नया उत्पाद लॉट पोस्ट करें',
    'post_new_produce_lot_desc': 'गुणवत्ता, मात्रा और मांग मूल्य के साथ कटी हुई फसल सूचीबद्ध करें',
    'my_active_lots_title': 'मेरे सक्रिय लॉट',
    'my_active_lots_desc': 'सूचीबद्ध फसलें, सक्रिय लॉट देखें और प्रस्ताव प्रबंधित करें',
    'buyer_demand_board_title': 'खरीदार मांग बोर्ड',
    'buyer_demand_board_desc': 'खरीदारों द्वारा पोस्ट की गई सक्रिय कमोडिटी आवश्यकताएं देखें',
    'dispatches_deals_title': 'डिस्पैच और सौदे',
    'dispatches_deals_desc': 'स्वीकृत सौदे, पिकअप और सीधे भुगतान ट्रैक करें',
    'intelligent_matching_title': 'इंटेलिजेंट खरीदार मिलान',
    'intelligent_matching_desc': 'संस्थागत खरीदारों के बीच शुद्ध प्राप्य दरों की तुलना करें',
    'buyer_demand_label': 'खरीदार मांग',
    'compare_net_price': 'शुद्ध मूल्य की तुलना करें',
    'delhi_ncr_distance': 'दिल्ली NCR • 65 किमी दूर',
    'wheat_demand_500': 'गेहूं • 500 क्विंटल आवश्यक',
    'net_rate_2520': '₹2,520/क्विंटल शुद्ध',
    'noida_hub_distance': 'नोएडा हब • 48 किमी दूर',
    'wheat_demand_200': 'गेहूं • 200 क्विंटल आवश्यक',
    'net_rate_2490': '₹2,490/क्विंटल शुद्ध',

    'procurement_index': 'खरीद सूचकांक',
    'active_market': 'सक्रिय बाज़ार',
    'per_quintal_benchmark_wheat': '/ क्विंटल बेंचमार्क (गेहूं)',
    'direct_procurement_savings_desc': 'सीधी खरीद से बिचौलियों के मंडी प्रबंधन और कमीशन शुल्क पर 8% तक की बचत होती है।',
    'post_commodity_demand_title': 'कमोडिटी मांग पोस्ट करें',
    'active_demands_badge': '{count} सक्रिय',
    'broadcast_demand_desc': 'अपनी आवश्यक मात्रा, लक्षित मूल्य और डिलीवरी स्थान प्रसारित करें',
    'browse_farmer_produce_lots': 'किसान उत्पाद लॉट ब्राउज़ करें',
    'my_submitted_offers_title': 'मेरे प्रस्तुत प्रस्ताव',
    'my_submitted_offers_desc': 'लंबित बोलियां, स्वीकृत सौदे और किसान के जवाबी प्रस्ताव ट्रैक करें',
    'direct_farmer_opportunities': 'प्रत्यक्ष किसान अवसर',
    'no_active_farmer_lots': 'वर्तमान में कोई सक्रिय किसान लॉट सूचीबद्ध नहीं है।',
    'volume_with_quality': 'मात्रा: {volume} • {quality}',
  };

  void _loadBuiltInStrings() {
    if (locale.languageCode == 'hi') {
      _localizedStrings = Map.from(_hiStrings);
    } else {
      _localizedStrings = Map.from(_enStrings);
    }
  }

  /// Loads strings from asset JSON files if available, merging them into memory.
  Future<bool> loadJsonAsset() async {
    try {
      final jsonString = await rootBundle
          .loadString('assets/lang/${locale.languageCode}.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      jsonMap.forEach((key, value) {
        _localizedStrings[key] = value.toString();
      });
      return true;
    } catch (_) {
      // Gracefully uses built-in strings if asset file is missing or in tests
      return false;
    }
  }

  /// Translates a given [key] into the active language.
  /// Any dynamic [args] replaced in `{param}` and the output text are
  /// strictly guaranteed to have English digits (0-9) via [NumberFormatter.ensureEnglishDigits].
  String translate(String key, {Map<String, dynamic>? args}) {
    var text = _localizedStrings[key] ?? _enStrings[key] ?? key;

    if (args != null && args.isNotEmpty) {
      args.forEach((argKey, argValue) {
        final val = NumberFormatter.ensureEnglishDigits(argValue.toString());
        text = text.replaceAll('{$argKey}', val);
      });
    }

    // Strict number formatting exception rule:
    // When language is Hindi, all numbers remain in English digits (0-9).
    return NumberFormatter.ensureEnglishDigits(text);
  }

  /// Convenient alias for [translate].
  String tr(String key, {Map<String, dynamic>? args}) =>
      translate(key, args: args);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLanguage.values
        .map((lang) => lang.code)
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.loadJsonAsset();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
