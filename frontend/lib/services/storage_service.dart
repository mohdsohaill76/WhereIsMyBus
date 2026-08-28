import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_item.dart';
import '../models/recent_activity_item.dart';

/// Centralized Local Storage Service for WhereIsMyBus V2
/// Encapsulates SharedPreferences with reactive ValueNotifiers for instantaneous UI updates.
class StorageService {
  static final StorageService instance = StorageService._internal();

  factory StorageService() => instance;

  StorageService._internal();

  static const String _keyFavorites = 'whereismybus_favorites';
  static const String _keyRecentActivity = 'whereismybus_recent_activity';
  static const int _maxRecentEntries = 15;

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  final ValueNotifier<List<FavoriteItem>> favoritesNotifier =
      ValueNotifier<List<FavoriteItem>>([]);

  final ValueNotifier<List<RecentActivityItem>> recentActivitiesNotifier =
      ValueNotifier<List<RecentActivityItem>>([]);

  /// Initializes storage and loads cached data into memory
  Future<void> init([SharedPreferences? customPrefs]) async {
    if (_isInitialized && customPrefs == null) return;

    _prefs = customPrefs ?? await SharedPreferences.getInstance();
    _loadFavorites();
    _loadRecentActivities();
    _isInitialized = true;
  }

  void _loadFavorites() {
    if (_prefs == null) return;
    try {
      final List<String>? rawList = _prefs!.getStringList(_keyFavorites);
      if (rawList != null) {
        final List<FavoriteItem> loaded = rawList
            .map((str) => FavoriteItem.fromJson(jsonDecode(str) as Map<String, dynamic>))
            .toList();
        favoritesNotifier.value = loaded;
      }
    } catch (_) {
      favoritesNotifier.value = [];
    }
  }

  void _loadRecentActivities() {
    if (_prefs == null) return;
    try {
      final List<String>? rawList = _prefs!.getStringList(_keyRecentActivity);
      if (rawList != null) {
        final List<RecentActivityItem> loaded = rawList
            .map((str) => RecentActivityItem.fromJson(jsonDecode(str) as Map<String, dynamic>))
            .toList();
        recentActivitiesNotifier.value = loaded;
      }
    } catch (_) {
      recentActivitiesNotifier.value = [];
    }
  }

  // ── Favorites Management ───────────────────────────────────────────────────

  List<FavoriteItem> getFavorites() {
    return List.unmodifiable(favoritesNotifier.value);
  }

  List<FavoriteItem> getFavoritesByType(String type) {
    return favoritesNotifier.value.where((item) => item.type == type).toList();
  }

  bool isFavorite(String type, String id) {
    return favoritesNotifier.value.any(
      (item) => item.type == type && item.id.toUpperCase() == id.toUpperCase(),
    );
  }

  Future<void> addFavorite(FavoriteItem item) async {
    if (isFavorite(item.type, item.id)) return;

    final updated = List<FavoriteItem>.from(favoritesNotifier.value)..insert(0, item);
    favoritesNotifier.value = updated;
    await _persistFavorites(updated);
  }

  Future<void> removeFavorite(String type, String id) async {
    final updated = favoritesNotifier.value
        .where((item) => !(item.type == type && item.id.toUpperCase() == id.toUpperCase()))
        .toList();
    favoritesNotifier.value = updated;
    await _persistFavorites(updated);
  }

  /// Toggles favorite status: returns true if added, false if removed
  Future<bool> toggleFavorite(FavoriteItem item) async {
    if (isFavorite(item.type, item.id)) {
      await removeFavorite(item.type, item.id);
      return false;
    } else {
      await addFavorite(item);
      return true;
    }
  }

  Future<void> _persistFavorites(List<FavoriteItem> list) async {
    _prefs ??= await SharedPreferences.getInstance();
    final stringList = list.map((item) => jsonEncode(item.toJson())).toList();
    await _prefs!.setStringList(_keyFavorites, stringList);
  }

  // ── Recent Activity Management ─────────────────────────────────────────────

  List<RecentActivityItem> getRecentActivities() {
    return List.unmodifiable(recentActivitiesNotifier.value);
  }

  Future<void> addRecentActivity(RecentActivityItem item) async {
    // Remove duplicate entry if it previously existed
    final updated = List<RecentActivityItem>.from(recentActivitiesNotifier.value)
      ..removeWhere((existing) => existing.type == item.type && existing.id.toUpperCase() == item.id.toUpperCase())
      ..insert(0, item);

    // Enforce max history capacity
    if (updated.length > _maxRecentEntries) {
      updated.removeRange(_maxRecentEntries, updated.length);
    }

    recentActivitiesNotifier.value = updated;
    await _persistRecentActivities(updated);
  }

  Future<void> clearRecentActivities() async {
    recentActivitiesNotifier.value = [];
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(_keyRecentActivity);
  }

  Future<void> _persistRecentActivities(List<RecentActivityItem> list) async {
    _prefs ??= await SharedPreferences.getInstance();
    final stringList = list.map((item) => jsonEncode(item.toJson())).toList();
    await _prefs!.setStringList(_keyRecentActivity, stringList);
  }

  /// Clears all local storage (useful for testing or reset)
  Future<void> clearAll() async {
    favoritesNotifier.value = [];
    recentActivitiesNotifier.value = [];
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(_keyFavorites);
    await _prefs!.remove(_keyRecentActivity);
  }
}
