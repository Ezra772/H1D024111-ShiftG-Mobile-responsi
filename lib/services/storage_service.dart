import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static const String _keyFavorites = 'weather_app_favorites';
  static const String _keyRecent = 'weather_app_recents';
  static const String _keyLastSelected = 'weather_app_last_selected';

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- Favorite Locations ---

  List<LocationModel> getFavorites() {
    final raw = _prefs.getStringList(_keyFavorites);
    if (raw == null) return [];
    try {
      return raw
          .map((item) => LocationModel.fromJson(json.decode(item)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveFavorites(List<LocationModel> list) async {
    final encoded = list.map((item) => json.encode(item.toJson())).toList();
    await _prefs.setStringList(_keyFavorites, encoded);
  }

  Future<bool> toggleFavorite(LocationModel location) async {
    final list = getFavorites();
    final index = list.indexWhere((item) => item.id == location.id);
    bool added;
    if (index >= 0) {
      list.removeAt(index);
      added = false;
    } else {
      list.add(location);
      added = true;
    }
    await saveFavorites(list);
    return added;
  }

  bool isFavorite(int locationId) {
    final list = getFavorites();
    return list.any((item) => item.id == locationId);
  }

  // --- Search History / Recents ---

  List<LocationModel> getRecentSearches() {
    final raw = _prefs.getStringList(_keyRecent);
    if (raw == null) return [];
    try {
      return raw
          .map((item) => LocationModel.fromJson(json.decode(item)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addRecentSearch(LocationModel location) async {
    final list = getRecentSearches();
    list.removeWhere((item) => item.id == location.id);
    list.insert(0, location);
    // Keep at most 10 recent searches
    if (list.length > 10) {
      list.removeRange(10, list.length);
    }
    final encoded = list.map((item) => json.encode(item.toJson())).toList();
    await _prefs.setStringList(_keyRecent, encoded);
  }

  Future<void> clearRecentSearches() async {
    await _prefs.remove(_keyRecent);
  }

  // --- Last Selected Location ---

  LocationModel? getLastSelectedLocation() {
    final raw = _prefs.getString(_keyLastSelected);
    if (raw == null) return null;
    try {
      return LocationModel.fromJson(json.decode(raw));
    } catch (e) {
      return null;
    }
  }

  Future<void> saveLastSelectedLocation(LocationModel location) async {
    await _prefs.setString(_keyLastSelected, json.encode(location.toJson()));
  }
}
