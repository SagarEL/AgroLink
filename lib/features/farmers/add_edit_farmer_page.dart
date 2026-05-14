import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:agrolink/core/theme/app_theme.dart';
import 'package:agrolink/core/utils/helpers.dart';
import 'package:agrolink/core/constants/app_constants.dart';
import 'package:agrolink/services/firestore_service.dart';
import 'package:agrolink/models/farmer_model.dart';

class AddEditFarmerPage extends ConsumerStatefulWidget {
  final String? farmerId;
  const AddEditFarmerPage({super.key, this.farmerId});
  @override
  ConsumerState<AddEditFarmerPage> createState() => _AddEditFarmerPageState();
}

class _AddEditFarmerPageState extends ConsumerState<AddEditFarmerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _villageController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isEdit = false;
  FarmerModel? _existingFarmer;

  @override
  void initState() {
    super.initState();
    if (widget.farmerId != null) {
      _isEdit = true;
      _loadFarmer();
    }
  }

  Future<void> _loadFarmer() async {
    final farmer = await ref.read(firestoreServiceProvider).getFarmer(widget.farmerId!);
    if (farmer != null && mounted) {
      setState(() {
        _existingFarmer = farmer;
        _nameController.text = farmer.farmerName;
        _phoneController.text = farmer.phone;
        _villageController.text = farmer.village;
        _addressController.text = farmer.address;
        _notesController.text = farmer.notes ?? '';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _villageController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final fs = ref.read(firestoreServiceProvider);
      final farmer = FarmerModel(
        farmerId: _existingFarmer?.farmerId ?? '',
        farmerName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        village: _villageController.text.trim(),
        address: _addressController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdBy: 'admin',
        createdAt: _existingFarmer?.createdAt ?? DateTime.now(),
        totalPlots: _existingFarmer?.totalPlots ?? 0,
        totalVisits: _existingFarmer?.totalVisits ?? 0,
      );

      if (_isEdit) {
        await fs.updateFarmer(farmer);
      } else {
        await fs.addFarmer(farmer);
      }

      if (mounted) {
        AppHelpers.showSuccess(context, _isEdit ? 'Farmer updated successfully' : 'Farmer added successfully');
        context.go('/farmers');
      }
    } catch (e) {
      if (mounted) AppHelpers.showError(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Farmer' : 'Add Farmer'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: AppTheme.glassCard,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          child: Icon(Icons.person_add_rounded,
                            color: AppTheme.primaryGreen, size: 36),
                        ),
                        const SizedBox(height: 12),
                        Text(_isEdit ? 'Edit Farmer Details' : 'New Farmer Registration',
                          style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1),
                  const SizedBox(height: 24),

                  // Form fields
                  _buildSection('Personal Information', [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Farmer Name *',
                        prefixIcon: Icon(Icons.person_outlined),
                      ),
                      validator: (v) => AppHelpers.validateRequired(v, 'Name'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number *',
                        prefixIcon: Icon(Icons.phone_outlined),
                        prefixText: '+91 ',
                      ),
                      validator: AppHelpers.validatePhone,
                    ),
                  ]).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),

                  _buildSection('Location', [
                    TextFormField(
                      controller: _villageController,
                      decoration: const InputDecoration(
                        labelText: 'Village *',
                        prefixIcon: Icon(Icons.location_city_outlined),
                      ),
                      validator: (v) => AppHelpers.validateRequired(v, 'Village'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Full Address *',
                        prefixIcon: Icon(Icons.map_outlined),
                        alignLabelWithHint: true,
                      ),
                      validator: (v) => AppHelpers.validateRequired(v, 'Address'),
                    ),
                  ]).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),

                  _buildSection('Additional Info', [
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        prefixIcon: Icon(Icons.note_outlined),
                        alignLabelWithHint: true,
                        hintText: 'Any additional notes about the farmer...',
                      ),
                    ),
                  ]).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: 32),

                  // Submit button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSave,
                      child: _isLoading
                          ? const SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(_isEdit ? 'Update Farmer' : 'Add Farmer',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
