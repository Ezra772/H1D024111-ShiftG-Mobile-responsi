import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  final storageService = await StorageService.init();
  final apiService = ApiService();

  runApp(
    WeatherApp(
      apiService: apiService,
      storageService: storageService,
    ),
  );
}

class WeatherApp extends StatelessWidget {
  final ApiService apiService;
  final StorageService storageService;

  const WeatherApp({
    super.key,
    required this.apiService,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        Provider<StorageService>.value(value: storageService),
        ChangeNotifierProvider<WeatherViewModel>(
          create: (_) => WeatherViewModel(
            apiService: apiService,
            storageService: storageService,
          ),
        ),
        ChangeNotifierProvider<SearchViewModel>(
          create: (_) => SearchViewModel(
            apiService: apiService,
            storageService: storageService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Info Cuaca (Open-Meteo)',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}
