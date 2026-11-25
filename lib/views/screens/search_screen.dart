import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/location_model.dart';
import '../../viewmodels/search_viewmodel.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_state_view.dart';
import '../widgets/glass_card.dart';

class SearchScreen extends StatefulWidget {
  final bool autofocusSearch;

  const SearchScreen({
    super.key,
    this.autofocusSearch = true,
  });

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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Consumer<SearchViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF285F8A),
                    Color(0xFF224B6B),
                    Color(0xFF17354D),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Top Glassmorphic Search Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: GlassCard(
                              borderRadius: 18,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 2,
                              ),
                              tintColor: Colors.white.withAlpha(32),
                              child: TextField(
                                controller: _searchController,
                                autofocus: widget.autofocusSearch,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                                cursorColor: Colors.white,
                                textInputAction: TextInputAction.search,
                                decoration: InputDecoration(
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  hintText:
                                      'Cari kota (misal: Bandung, Tokyo)...',
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withAlpha(160),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: Colors.white.withAlpha(200),
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.close_rounded,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                            vm.onQueryChanged('');
                                          },
                                        )
                                      : null,
                                ),
                                onChanged: vm.onQueryChanged,
                                onSubmitted: (query) => vm.search(query),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Body Content
                    Expanded(child: _buildBody(vm)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(SearchViewModel vm) {
    if (vm.state == SearchViewState.searching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(
              'Mencari lokasi "${vm.currentQuery}"...',
              style: TextStyle(
                color: Colors.white.withAlpha(210),
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
        message:
            'Tidak ada hasil untuk "${vm.currentQuery}". Coba periksa ejaan nama kota.',
      );
    }

    if (vm.state == SearchViewState.success) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: vm.searchResults.length,
        itemBuilder: (context, index) {
          final loc = vm.searchResults[index];
          final isFav = vm.isFavorite(loc.id);

          return GlassCard(
            borderRadius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_city_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                loc.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                loc.displayName,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.white.withAlpha(180),
                ),
              ),
              trailing: IconButton(
                tooltip: isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                icon: Icon(
                  isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFav
                      ? const Color(0xFFFF6B6B)
                      : Colors.white.withAlpha(180),
                ),
                onPressed: () => vm.toggleFavorite(loc),
              ),
              onTap: () => _selectLocation(loc),
            ),
          );
        },
      );
    }

    // Idle State: Favorites & Recent Searches
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Lokasi Favorit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFFF6B6B),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Lokasi Favorit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                '${vm.favorites.length} Lokasi',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.white.withAlpha(180),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (vm.favorites.isEmpty)
            GlassCard(
              borderRadius: 18,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white.withAlpha(180),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Belum ada lokasi favorit. Tekan ikon hati pada kota untuk menyimpannya.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withAlpha(195),
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
                return GlassCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B).withAlpha(45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFFFF6B6B),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      loc.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      loc.displayName,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.white.withAlpha(180),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: Colors.white.withAlpha(185),
                      ),
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
                const Row(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      color: Color(0xFF7DD3FC),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Riwayat Pencarian',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => vm.clearRecentSearches(),
                  child: const Text(
                    'Hapus Semua',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFFFCA5A5),
                      fontWeight: FontWeight.w600,
                    ),
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
                return GlassCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.history_rounded,
                        color: Colors.white.withAlpha(200),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      loc.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15.5,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      loc.displayName,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.white.withAlpha(180),
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.white.withAlpha(160),
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
