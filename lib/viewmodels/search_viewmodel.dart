import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

enum SearchViewState { idle, searching, success, empty, error }

class SearchViewModel extends ChangeNotifier {
  final ApiService apiService;
  final StorageService storageService;

  SearchViewModel({
    required this.apiService,
    required this.storageService,
  }) {
    loadStoredData();
  }

  SearchViewState _state = SearchViewState.idle;
  List<LocationModel> _searchResults = [];
  List<LocationModel> _favorites = [];
  List<LocationModel> _recentSearches = [];
  String? _errorMessage;
  String _currentQuery = '';
  Timer? _debounceTimer;

  SearchViewState get state => _state;
  List<LocationModel> get searchResults => _searchResults;
  List<LocationModel> get favorites => _favorites;
  List<LocationModel> get recentSearches => _recentSearches;
  String? get errorMessage => _errorMessage;
  String get currentQuery => _currentQuery;

  /// Load favorites and recent searches from local storage
  void loadStoredData() {
    _favorites = storageService.getFavorites();
    _recentSearches = storageService.getRecentSearches();
    notifyListeners();
  }

  /// Debounced search trigger for user typing
  void onQueryChanged(String query) {
    _currentQuery = query;
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      _state = SearchViewState.idle;
      _searchResults = [];
      _errorMessage = null;
      loadStoredData();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      search(query);
    });
  }

  /// Execute search query to API
  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _state = SearchViewState.idle;
      _searchResults = [];
      notifyListeners();
      return;
    }

    _state = SearchViewState.searching;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await apiService.searchLocations(trimmed);
      if (results.isEmpty) {
        _state = SearchViewState.empty;
        _searchResults = [];
      } else {
        _state = SearchViewState.success;
        _searchResults = results;
      }
    } catch (e) {
      _state = SearchViewState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  /// Toggle favorite from search list or favorites list
  Future<void> toggleFavorite(LocationModel location) async {
    await storageService.toggleFavorite(location);
    loadStoredData();
  }

  bool isFavorite(int locationId) {
    return storageService.isFavorite(locationId);
  }

  /// Clear recent search history
  Future<void> clearRecentSearches() async {
    await storageService.clearRecentSearches();
    _recentSearches = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
