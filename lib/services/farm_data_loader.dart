import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';
import 'farm_snapshot.dart';

abstract class FarmDataLoader {
  Future<List<CropItem>> fetchCropsCatalog();

  /// Returns the authenticated user's farm data, or null when nobody is signed in.
  Future<FarmSnapshot?> fetchFarmData();
}

class SupabaseFarmDataLoader implements FarmDataLoader {
  SupabaseFarmDataLoader(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<List<CropItem>> fetchCropsCatalog() async {
    final cropsRes = await _supabase.from('crops').select();
    return (cropsRes as List).map((c) => CropItem.fromJson(c)).toList();
  }

  @override
  Future<FarmSnapshot?> fetchFarmData() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return null;

    final userId = session.user.id;

    final profileRes =
        await _supabase.from('profiles').select().eq('id', userId).maybeSingle();
    final profile = profileRes != null ? UserProfile.fromJson(profileRes) : null;

    final userCropsRes = await _supabase
        .from('user_crops')
        .select('id, crop_id, crops(*)')
        .eq('user_id', userId);
    final userCrops = (userCropsRes as List)
        .map((uc) => CropItem.fromJson(uc['crops']))
        .toList();

    final historyRes = await _supabase
        .from('scan_history')
        .select()
        .eq('user_id', userId)
        .order('scanned_at', ascending: false);
    final scanHistory =
        (historyRes as List).map((h) => ScanHistoryItem.fromJson(h)).toList();

    final notifRes = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    final notifications =
        (notifRes as List).map((n) => AppNotification.fromJson(n)).toList();

    var calendarEvents = await _fetchCalendar(userId);
    if (calendarEvents.isEmpty && userCrops.isNotEmpty) {
      await _generateDefaultCalendarEvents(userId);
      calendarEvents = await _fetchCalendar(userId);
    }

    return FarmSnapshot(
      availableCrops: const [],
      userCrops: userCrops,
      scanHistory: scanHistory,
      notifications: notifications,
      calendarEvents: calendarEvents,
      fetchedAt: DateTime.now(),
      profile: profile,
    );
  }

  Future<List<CropCalendarEvent>> _fetchCalendar(String userId) async {
    final res = await _supabase
        .from('crop_calendar_events')
        .select()
        .eq('user_id', userId)
        .order('scheduled_date', ascending: true);
    return (res as List).map((c) => CropCalendarEvent.fromJson(c)).toList();
  }

  Future<void> _generateDefaultCalendarEvents(String userId) async {
    final now = DateTime.now();
    final defaultEvents = [
      {
        'user_id': userId,
        'event_title': 'Soil Organic Enrichment & Composting',
        'event_category': 'Nutrition',
        'scheduled_date': now.toIso8601String(),
        'is_completed': false,
        'priority': 'High'
      },
      {
        'user_id': userId,
        'event_title': 'Deep Root Irrigation & Moisture Check',
        'event_category': 'Water Management',
        'scheduled_date': now.add(const Duration(days: 1)).toIso8601String(),
        'is_completed': false,
        'priority': 'Normal'
      },
      {
        'user_id': userId,
        'event_title': 'Preventive Fungal Inspection (Neem Oil)',
        'event_category': 'Pest Control',
        'scheduled_date': now.add(const Duration(days: 3)).toIso8601String(),
        'is_completed': false,
        'priority': 'High'
      },
      {
        'user_id': userId,
        'event_title': 'Growth Stage Audit & Foliar Feeding',
        'event_category': 'Harvesting',
        'scheduled_date': now.add(const Duration(days: 7)).toIso8601String(),
        'is_completed': false,
        'priority': 'Normal'
      },
    ];

    for (final event in defaultEvents) {
      try {
        await _supabase.from('crop_calendar_events').insert(event);
      } catch (_) {}
    }
  }
}
