import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/features/pro/domain/entitlement.dart';

/// Liveness of the farmer's Agri Pro entitlement, read from `user_subscriptions`.
///
/// The row is the source of truth. When the read fails the last known view
/// is kept and an [errorMessage] is exposed; first-load failures fall back
/// to free.
class AgriProEntitlement with ChangeNotifier {
  AgriProEntitlement({
    SupabaseClient? supabase,
    Future<Map<String, dynamic>?> Function()? fetchRow,
  })  : _supabase = supabase ?? Supabase.instance.client,
        _fetchRowOverride = fetchRow;

  final SupabaseClient _supabase;
  final Future<Map<String, dynamic>?> Function()? _fetchRowOverride;

  EntitlementView _view = EntitlementView.free;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isPro => _view.isPro;
  String? get planId => _view.planId;
  DateTime? get expiresAt => _view.expiresAt;
  EntitlementTier get tier => _view.tier;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final row = _fetchRowOverride != null ? await _fetchRowOverride() : await _fetchRow();
      _view = evaluateEntitlement(
        tier: row?['tier'] as String?,
        expiresAt: row?['expires_at'] != null
            ? DateTime.tryParse(row!['expires_at'].toString())
            : null,
        now: DateTime.now(),
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load();

  Future<Map<String, dynamic>?> _fetchRow() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return null;
    final row = await _supabase
        .from('user_subscriptions')
        .select('tier, expires_at')
        .eq('user_id', session.user.id)
        .maybeSingle();
    return row;
  }
}
