import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:agrolink/core/theme/app_theme.dart';
import 'package:agrolink/core/utils/helpers.dart';
import 'package:agrolink/core/utils/responsive.dart';
import 'package:agrolink/services/firestore_service.dart';
import 'package:agrolink/models/farmer_model.dart';
import 'package:agrolink/models/visit_model.dart';
import 'package:agrolink/models/plot_model.dart';

class FarmerDetailPage extends ConsumerWidget {
  final String farmerId;
  const FarmerDetailPage({super.key, required this.farmerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = ref.read(firestoreServiceProvider);
    final padding = Responsive.contentPadding(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/farmers'),
        ),
        title: const Text('Farmer Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => context.go('/farmers/$farmerId/edit'),
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Farmer'),
                    content: const Text('Are you sure? This action cannot be undone.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await fs.deleteFarmer(farmerId);
                  if (context.mounted) context.go('/farmers');
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'delete', child: Row(
                children: [Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
                  SizedBox(width: 8), Text('Delete', style: TextStyle(color: AppTheme.error))],
              )),
            ],
          ),
        ],
      ),
      body: FutureBuilder<FarmerModel?>(
        future: fs.getFarmer(farmerId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final farmer = snap.data;
          if (farmer == null) {
            return const Center(child: Text('Farmer not found'));
          }

          return SingleChildScrollView(
            padding: padding,
            child: Responsive.isDesktop(context)
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildProfileCard(context, farmer)),
                      const SizedBox(width: 20),
                      Expanded(flex: 3, child: _buildDetailsSection(context, ref, farmer)),
                    ],
                  )
                : Column(
                    children: [
                      _buildProfileCard(context, farmer),
                      const SizedBox(height: 20),
                      _buildDetailsSection(context, ref, farmer),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, FarmerModel farmer) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassCard,
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
            child: Text(AppHelpers.getInitials(farmer.farmerName),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen)),
          ),
          const SizedBox(height: 16),
          Text(farmer.farmerName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(farmer.village,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textTertiary)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statItem(context, '${farmer.totalPlots}', 'Plots', AppTheme.primaryGreen),
              _statItem(context, '${farmer.totalVisits}', 'Visits', AppTheme.info),
              _statItem(context, farmer.lastVisitDate != null
                  ? AppHelpers.timeAgo(DateTime.parse(farmer.lastVisitDate!)) : 'N/A',
                'Last Visit', AppTheme.accentAmber),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          _infoRow(context, Icons.phone_rounded, 'Phone', farmer.phone),
          _infoRow(context, Icons.location_on_rounded, 'Address', farmer.address),
          if (farmer.notes != null && farmer.notes!.isNotEmpty)
            _infoRow(context, Icons.note_rounded, 'Notes', farmer.notes!),
          _infoRow(context, Icons.calendar_today_rounded, 'Member Since',
            AppHelpers.formatDate(farmer.createdAt)),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _statItem(BuildContext context, String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary)),
      ],
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textTertiary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.textTertiary)),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, WidgetRef ref, FarmerModel farmer) {
    return Column(
      children: [
        // Plots section
        _buildPlotsSection(context, ref, farmer),
        const SizedBox(height: 20),
        // Visit history
        _buildVisitsSection(context, ref, farmer),
      ],
    );
  }

  Widget _buildPlotsSection(BuildContext context, WidgetRef ref, FarmerModel farmer) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Plots', style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Plot'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<PlotModel>>(
            stream: ref.read(firestoreServiceProvider).streamPlotsByFarmer(farmerId),
            builder: (context, snap) {
              if (!snap.hasData || snap.data!.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  child: const Center(child: Text('No plots yet', style: TextStyle(color: AppTheme.textTertiary))),
                );
              }
              return Column(
                children: snap.data!.asMap().entries.map((e) {
                  final plot = e.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.grid_view_rounded, color: AppTheme.primaryGreen, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(plot.cropType, style: Theme.of(context).textTheme.titleSmall),
                              Text('${plot.acreage} acres • ${plot.location}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppHelpers.severityColor(plot.priorityLevel).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(plot.diseaseStatus,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                              color: AppHelpers.severityColor(plot.priorityLevel))),
                        ),
                      ],
                    ),
                  ).animate(delay: (e.key * 80).ms).fadeIn().slideX(begin: 0.1);
                }).toList(),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildVisitsSection(BuildContext context, WidgetRef ref, FarmerModel farmer) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Visit History', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          StreamBuilder<List<VisitModel>>(
            stream: ref.read(firestoreServiceProvider).streamVisitsByFarmer(farmerId),
            builder: (context, snap) {
              if (!snap.hasData || snap.data!.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  child: const Center(child: Text('No visits yet', style: TextStyle(color: AppTheme.textTertiary))),
                );
              }
              return Column(
                children: snap.data!.take(5).toList().asMap().entries.map((e) {
                  final visit = e.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border(left: BorderSide(
                        color: AppHelpers.severityColor(visit.severity), width: 3)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppHelpers.formatDate(visit.visitDate),
                                style: Theme.of(context).textTheme.titleSmall),
                              if (visit.diseaseObserved.isNotEmpty)
                                Text(visit.diseaseObserved.join(', '),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary)),
                            ],
                          ),
                        ),
                        Icon(AppHelpers.visitStatusIcon(visit.status),
                          color: AppHelpers.visitStatusColor(visit.status), size: 20),
                      ],
                    ),
                  ).animate(delay: (e.key * 80).ms).fadeIn().slideX(begin: 0.1);
                }).toList(),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }
}
