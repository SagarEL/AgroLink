import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:agrolink/core/theme/app_theme.dart';
import 'package:agrolink/core/utils/responsive.dart';
import 'package:agrolink/core/utils/helpers.dart';
import 'package:agrolink/services/firestore_service.dart';
import 'package:agrolink/models/farmer_model.dart';
import 'package:agrolink/widgets/empty_state.dart';
import 'package:agrolink/widgets/shimmer_loading.dart';

final farmersStreamProvider = StreamProvider<List<FarmerModel>>((ref) {
  return ref.read(firestoreServiceProvider).streamFarmers();
});

class FarmersListPage extends ConsumerStatefulWidget {
  const FarmersListPage({super.key});
  @override
  ConsumerState<FarmersListPage> createState() => _FarmersListPageState();
}

class _FarmersListPageState extends ConsumerState<FarmersListPage> {
  String _searchQuery = '';
  String? _selectedVillage;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final farmersAsync = ref.watch(farmersStreamProvider);
    final padding = Responsive.contentPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmers'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list_rounded), onPressed: _showFilterSheet),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding.horizontal / 2, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search farmers by name, village, phone...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        })
                    : null,
              ),
            ),
          ).animate().fadeIn().slideY(begin: -0.1),
          // Farmer list
          Expanded(
            child: farmersAsync.when(
              loading: () => ListView.builder(
                padding: padding,
                itemCount: 6,
                itemBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: ShimmerCard(),
                ),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (farmers) {
                var filtered = farmers;
                if (_searchQuery.isNotEmpty) {
                  filtered = filtered.where((f) =>
                    f.farmerName.toLowerCase().contains(_searchQuery) ||
                    f.village.toLowerCase().contains(_searchQuery) ||
                    f.phone.contains(_searchQuery)).toList();
                }
                if (_selectedVillage != null) {
                  filtered = filtered.where((f) => f.village == _selectedVillage).toList();
                }

                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.people_outline_rounded,
                    title: 'No Farmers Found',
                    subtitle: _searchQuery.isNotEmpty
                        ? 'Try a different search term'
                        : 'Add your first farmer to get started',
                    actionLabel: 'Add Farmer',
                    onAction: () => context.go('/farmers/add'),
                  );
                }

                return Responsive.isDesktop(context)
                    ? _buildGridView(filtered, padding)
                    : _buildListView(filtered, padding);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/farmers/add'),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Farmer'),
      ).animate().scale(delay: 300.ms, duration: 300.ms, curve: Curves.elasticOut),
    );
  }

  Widget _buildListView(List<FarmerModel> farmers, EdgeInsets padding) {
    return ListView.builder(
      padding: padding,
      itemCount: farmers.length,
      itemBuilder: (context, index) {
        return _FarmerCard(farmer: farmers[index])
            .animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.05);
      },
    );
  }

  Widget _buildGridView(List<FarmerModel> farmers, EdgeInsets padding) {
    return GridView.builder(
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.value(context, mobile: 1, tablet: 2, desktop: 3),
        crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 2.8,
      ),
      itemCount: farmers.length,
      itemBuilder: (context, index) {
        return _FarmerCard(farmer: farmers[index])
            .animate(delay: (index * 50).ms).fadeIn().scale(begin: const Offset(0.95, 0.95));
      },
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter Farmers', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            Text('Village', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: ['All', 'Shirur', 'Baramati', 'Indapur', 'Daund'].map((v) {
                final selected = v == 'All' ? _selectedVillage == null : _selectedVillage == v;
                return ChoiceChip(
                  label: Text(v),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _selectedVillage = v == 'All' ? null : v);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _FarmerCard extends StatelessWidget {
  final FarmerModel farmer;
  const _FarmerCard({required this.farmer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.go('/farmers/${farmer.farmerId}'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.glassCard,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  child: Text(
                    AppHelpers.getInitials(farmer.farmerName),
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(farmer.farmerName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textTertiary),
                          const SizedBox(width: 4),
                          Text(farmer.village,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary)),
                          const SizedBox(width: 12),
                          Icon(Icons.phone_outlined, size: 14, color: AppTheme.textTertiary),
                          const SizedBox(width: 4),
                          Text(farmer.phone,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${farmer.totalPlots} plots',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryGreen)),
                    ),
                    const SizedBox(height: 4),
                    Text('${farmer.totalVisits} visits',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary)),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
