import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../models/weather_data.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

enum WeatherViewState { initial, loading, loaded, error }

class WeatherViewModel extends ChangeNotifier {
  final ApiService apiService;
  final StorageService storageService;

  WeatherViewModel({
    required this.apiService,
    required this.storageService,
  });

  WeatherViewState _state = WeatherViewState.initial;
  WeatherData? _weatherData;
  LocationModel? _currentLocation;
  String? _errorMessage;
  bool _isFavorite = false;

  WeatherViewState get state => _state;
  WeatherData? get weatherData => _weatherData;
  LocationModel? get currentLocation => _currentLocation;
  String? get errorMessage => _errorMessage;
  bool get isFavorite => _isFavorite;
  bool get isLoading => _state == WeatherViewState.loading;

  // Default fallback location (Jakarta)
  static final LocationModel defaultLocation = LocationModel(
    id: 1642911,
    name: 'Jakarta',
    latitude: -6.21462,
    longitude: 106.84513,
    country: 'Indonesia',
    admin1: 'DKI Jakarta',
    timezone: 'Asia/Jakarta',
  );

  /// Initialize viewmodel on app launch: read last selected location or use default
  Future<void> init() async {
    final savedLocation = storageService.getLastSelectedLocation();
    final targetLocation = savedLocation ?? defaultLocation;
    await loadWeather(targetLocation);
  }

  /// Fetch weather for a given location
  Future<void> loadWeather(LocationModel location) async {
    _currentLocation = location;
    _state = WeatherViewState.loading;
    _errorMessage = null;
    _isFavorite = storageService.isFavorite(location.id);
    notifyListeners();

    try {
      final data = await apiService.getForecast(location);
      _weatherData = data;
      _state = WeatherViewState.loaded;

      // Save as last selected & record in recents
      await storageService.saveLastSelectedLocation(location);
      await storageService.addRecentSearch(location);
      _isFavorite = storageService.isFavorite(location.id);
    } catch (e) {
      _state = WeatherViewState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  /// Refresh weather data for current location
  Future<void> refreshWeather() async {
    if (_currentLocation != null) {
      try {
        final data = await apiService.getForecast(_currentLocation!);
        _weatherData = data;
        _isFavorite = storageService.isFavorite(_currentLocation!.id);
        notifyListeners();
      } catch (e) {
        // If refresh fails while we already have data, we keep data but can notify or retain
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        notifyListeners();
      }
    }
  }

  /// Toggle favorite status of current location
  Future<void> toggleFavorite() async {
    if (_currentLocation == null) return;
    final nowFav = await storageService.toggleFavorite(_currentLocation!);
    _isFavorite = nowFav;
    notifyListeners();
  }

  /// Check and update favorite status (e.g., when returning from search screen)
  void updateFavoriteStatus() {
    if (_currentLocation != null) {
      final fav = storageService.isFavorite(_currentLocation!.id);
      if (fav != _isFavorite) {
        _isFavorite = fav;
        notifyListeners();
      }
    }
  }
}
