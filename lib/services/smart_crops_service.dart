import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/features/calendar/domain/task_draft.dart';
import '../features/shop/domain/merchant_product.dart';
import '../models/app_models.dart';
import 'farm_data_loader.dart';
import 'farm_snapshot.dart';
import 'service_data_cache_store.dart';

class SmartCropsService with ChangeNotifier {
  SmartCropsService({
    SupabaseClient? supabase,
    ServiceDataCacheStore? cacheStore,
    FarmDataLoader? loader,
  })  : _supabase = supabase ?? Supabase.instance.client,
        _cacheStore = cacheStore ?? ServiceDataCacheStore() {
    _loader = loader ?? SupabaseFarmDataLoader(_supabase);
  }

  final SupabaseClient _supabase;
  final ServiceDataCacheStore _cacheStore;
  late final FarmDataLoader _loader;
  RealtimeChannel? _realtimeChannel;
  bool _realtimeStarted = false;

  UserProfile? _currentUserProfile;
  List<CropItem> _availableCrops = [];
  List<CropItem> _userSelectedCrops = [];
  List<ScanHistoryItem> _scanHistory = [];
  List<AppNotification> _notifications = [];
  List<CropCalendarEvent> _calendarEvents = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;

  UserProfile? get currentUserProfile => _currentUserProfile;
  List<CropItem> get availableCrops => _availableCrops;
  List<CropItem> get userSelectedCrops => _userSelectedCrops;
  List<ScanHistoryItem> get scanHistory => _scanHistory;
  List<AppNotification> get notifications => _notifications;
  List<CropCalendarEvent> get calendarEvents => _calendarEvents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;

  int get unreadNotificationCount => _notifications.where((n) => !n.isRead).length;

  void _applySnapshot(FarmSnapshot snapshot) {
    _availableCrops = snapshot.availableCrops;
    _userSelectedCrops = snapshot.userCrops;
    _scanHistory = snapshot.scanHistory;
    _notifications = snapshot.notifications;
    _calendarEvents = snapshot.calendarEvents;
    _currentUserProfile = snapshot.profile ?? _currentUserProfile;
    _lastUpdated = snapshot.fetchedAt;
  }

  Future<void> initializeUserData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final catalog = await _loader.fetchCropsCatalog();
      final data = await _loader.fetchFarmData();

      if (data == null) {
        // Nobody signed in: keep the public catalog, never expose cached
        // private data or overwrite the cache with an empty snapshot.
        _availableCrops = catalog;
        _userSelectedCrops = [];
        _scanHistory = [];
        _notifications = [];
        _calendarEvents = [];
        return;
      }

      final snapshot = FarmSnapshot(
        availableCrops: catalog,
        userCrops: data.userCrops,
        scanHistory: data.scanHistory,
        notifications: data.notifications,
        calendarEvents: data.calendarEvents,
        fetchedAt: data.fetchedAt,
        profile: data.profile,
      );
      _applySnapshot(snapshot);
      await _cacheStore.save(snapshot);
    } catch (e) {
      debugPrint('Error initializing user data, falling back to cache: $e');
      final cached = await _cacheStore.load();
      if (cached != null) {
        _applySnapshot(cached);
      } else {
        _errorMessage = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> toggleCalendarEventCompletion(String eventId, bool isCompleted) async {
    final session = _supabase.auth.currentSession;
    if (session == null) return;

    await _supabase.from('crop_calendar_events').update({'is_completed': isCompleted}).eq('id', eventId);
    await initializeUserData();
  }

  Future<void> addCalendarEvent(TaskDraft draft) async {
    final session = _supabase.auth.currentSession;
    if (session == null) throw StateError('Not signed in');

    await _supabase.from('crop_calendar_events').insert(draft.toInsert(session.user.id));
    await initializeUserData();
  }

  Future<void> updateCalendarEvent(String eventId, TaskDraft draft) async {
    final session = _supabase.auth.currentSession;
    if (session == null) throw StateError('Not signed in');

    await _supabase.from('crop_calendar_events').update(draft.toUpdate()).eq('id', eventId);
    await initializeUserData();
  }

  Future<void> deleteCalendarEvent(String eventId) async {
    final session = _supabase.auth.currentSession;
    if (session == null) throw StateError('Not signed in');

    await _supabase.from('crop_calendar_events').delete().eq('id', eventId);
    await initializeUserData();
  }

  /// Agri Shop (blueprint Sec 5.16): public read of partner products.
  Future<List<MerchantProduct>> fetchMerchantProducts() async {
    final rows = await _supabase
        .from('merchant_products')
        .select()
        .order('created_at', ascending: true);
    return (rows as List)
        .map((row) => MerchantProduct.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<MerchantProduct?> fetchMerchantProductById(String productId) async {
    final row =
        await _supabase.from('merchant_products').select().eq('id', productId).maybeSingle();
    return row == null ? null : MerchantProduct.fromJson(row);
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
    await initializeUserData();
  }

  Future<void> signUpWithEmail(String email, String password, String fullName, String farmName, String location, String? phoneNumber) async {
    final res = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'farm_name': farmName,
        'location': location,
        'phone_number': phoneNumber,
      },
    );
    if (res.user != null) {
      await initializeUserData();
    }
  }

  /// Subscribe to realtime notification inserts (blueprint Sec 4, Phase 2).
  /// Best-effort: a backend without realtime, or a missing publication,
  /// must never crash the app.
  Future<void> startRealtimeNotifications() async {
    if (_realtimeStarted) return;
    final session = _supabase.auth.currentSession;
    if (session == null) return;
    _realtimeStarted = true;
    try {
      _realtimeChannel = _supabase
          .channel('public:notifications:${session.user.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'notifications',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: session.user.id,
            ),
            callback: (payload) {
              try {
                final notification =
                    AppNotification.fromJson(payload.newRecord);
                _notifications = [notification, ..._notifications];
                notifyListeners();
              } catch (_) {
                // A row shape mismatch should never crash the app.
              }
            },
          )
          .subscribe();
    } catch (_) {
      _realtimeStarted = false;
    }
  }

  Future<void> stopRealtimeNotifications() async {
    final channel = _realtimeChannel;
    _realtimeChannel = null;
    _realtimeStarted = false;
    if (channel != null) {
      try {
        await _supabase.removeChannel(channel);
      } catch (_) {
        // Ignored: realtime teardown is best-effort.
      }
    }
  }

  Future<void> signOut() async {
    final userId = _supabase.auth.currentSession?.user.id;
    await stopRealtimeNotifications();
    if (userId != null) {
      try {
        await _supabase.from('device_tokens').delete().eq('user_id', userId);
      } catch (_) {
        // Best-effort: a stale token is preferable to a blocked sign-out.
      }
    }
    await _supabase.auth.signOut();
    _currentUserProfile = null;
    _userSelectedCrops = [];
    _scanHistory = [];
    _notifications = [];
    notifyListeners();
  }

  Future<void> updateProfile(String fullName, String farmName, String location, String? phoneNumber) async {
    final session = _supabase.auth.currentSession;
    if (session == null) return;
    final userId = session.user.id;

    await _supabase.from('profiles').update({
      'full_name': fullName,
      'farm_name': farmName,
      'location': location,
      'phone_number': phoneNumber,
    }).eq('id', userId);

    await initializeUserData();
  }

  Future<void> saveUserCrops(List<String> cropIds) async {
    final session = _supabase.auth.currentSession;
    if (session == null) return;
    final userId = session.user.id;

    // Delete existing selections
    await _supabase.from('user_crops').delete().eq('user_id', userId);

    // Insert new selections
    for (var cropId in cropIds) {
      await _supabase.from('user_crops').insert({
        'user_id': userId,
        'crop_id': cropId,
      });
    }

    await initializeUserData();
  }

  Future<ScanHistoryItem?> performAiScan(String imageUrl, String cropName) async {
    final session = _supabase.auth.currentSession;
    if (session == null) return null;

    _isLoading = true;
    notifyListeners();

    try {
      // Invoke Supabase Edge Function 'scan-crop'
      final response = await _supabase.functions.invoke(
        'scan-crop',
        body: {
          'imageUrl': imageUrl,
          'userId': session.user.id,
          'cropName': cropName,
        },
      );

      // Only a real, AI-backed 200 with parseable data counts as a scan.
      // The edge function returns 502 when every key failed, so nothing fake
      // is inserted into scan_history on the failure path.
      if (response.status == 200 && response.data != null) {
        final data = response.data['data'];
        if (data == null) {
          return null;
        }
        final scanItem = ScanHistoryItem.fromJson(data);
        _scanHistory.insert(0, scanItem);

        // Refresh notifications
        await initializeUserData();
        return scanItem;
      }
    } catch (e) {
      debugPrint('AI Scan Edge Function failed: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _supabase.from('notifications').update({'is_read': true}).eq('id', notificationId);
    await initializeUserData();
  }

  Future<void> signInWithPhoneOtp(String phoneNumber) async {
    try {
      await _supabase.auth.signInWithOtp(
        phone: phoneNumber,
      );
    } catch (e) {
      debugPrint('Phone OTP send error: $e');
      rethrow;
    }
  }

  Future<void> verifyPhoneOtp(String phoneNumber, String token) async {
    try {
      final res = await _supabase.auth.verifyOTP(
        phone: phoneNumber,
        token: token,
        type: OtpType.sms,
      );
      if (res.user != null) {
        await initializeUserData();
      }
    } catch (e) {
      debugPrint('Phone OTP verify error: $e');
      rethrow;
    }
  }

  Future<bool> signInWithOAuth(dynamic provider) async {
    try {
      return await _supabase.auth.signInWithOAuth(
        provider,
        redirectTo: kIsWeb ? '${Uri.base.origin}/' : null,
      );
    } catch (e) {
      debugPrint('OAuth sign-in error: $e');
      rethrow;
    }
  }
}
