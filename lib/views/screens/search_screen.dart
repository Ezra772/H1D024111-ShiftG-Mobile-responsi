import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/location_model.dart';
import '../../viewmodels/search_viewmodel.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_state_view.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchViewModel>().loadStoredData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectLocation(LocationModel location) {
    context.read<WeatherViewModel>().loadWeather(location);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          appBar: AppBar(
            title: TextField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari nama kota (misal: Bandung, Tokyo)...',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          vm.onQueryChanged('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: vm.onQueryChanged,
              onSubmitted: (query) => vm.search(query),
            ),
          ),
          body: _buildBody(vm),
        );
      },
    );
  }

  Widget _buildBody(SearchViewModel vm) {
    // If user is actively searching
    if (vm.state == SearchViewState.searching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Mencari lokasi "${vm.currentQuery}"...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (vm.state == SearchViewState.error) {
      return ErrorStateView(
        message: vm.errorMessage ?? 'Gagal mencari lokasi.',
        onRetry: () => vm.search(vm.currentQuery),
      );
    }

    if (vm.state == SearchViewState.empty) {
      return EmptyStateView(
        icon: Icons.location_off_rounded,
        title: 'Lokasi Tidak Ditemukan',
        message: 'Tidak ada hasil untuk "${vm.currentQuery}". Coba periksa ejaan nama kota.',
      );
    }

    if (vm.state == SearchViewState.success) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: vm.searchResults.length,
        itemBuilder: (context, index) {
          final loc = vm.searchResults[index];
          final isFav = vm.isFavorite(loc.id);

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_city_rounded,
                  color: Color(0xFF1E88E5),
                ),
              ),
              title: Text(
                loc.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                loc.displayName,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              trailing: IconButton(
                tooltip: isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                icon: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? Colors.redAccent : Colors.grey.shade400,
                ),
                onPressed: () => vm.toggleFavorite(loc),
              ),
              onTap: () => _selectLocation(loc),
            ),
          );
        },
      );
    }

    // Default Idle State: show Favorites and Recent Searches
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Lokasi Favorit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Lokasi Favorit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Text(
                '${vm.favorites.length} Lokasi',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (vm.favorites.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.grey.shade400),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Belum ada lokasi favorit. Tekan ikon hati pada kota untuk menyimpannya.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vm.favorites.length,
              itemBuilder: (context, index) {
                final loc = vm.favorites[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      loc.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      loc.displayName,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      tooltip: 'Hapus Favorit',
                      onPressed: () => vm.toggleFavorite(loc),
                    ),
                    onTap: () => _selectLocation(loc),
                  ),
                );
              },
            ),

          const SizedBox(height: 24),

          // Section 2: Riwayat Pencarian Terakhir
          if (vm.recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history_rounded, color: Color(0xFF1E88E5), size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Riwayat Pencarian',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => vm.clearRecentSearches(),
                  child: const Text(
                    'Hapus Semua',
                    style: TextStyle(fontSize: 12, color: Colors.redAccent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vm.recentSearches.length,
              itemBuilder: (context, index) {
                final loc = vm.recentSearches[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.history_rounded,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      loc.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      loc.displayName,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.grey,
                    ),
                    onTap: () => _selectLocation(loc),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
