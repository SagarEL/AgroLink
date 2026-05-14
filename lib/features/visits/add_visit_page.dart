import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:agrolink/core/theme/app_theme.dart';
import 'package:agrolink/core/utils/helpers.dart';
import 'package:agrolink/core/constants/app_constants.dart';
import 'package:agrolink/services/firestore_service.dart';
import 'package:agrolink/models/visit_model.dart';
import 'package:agrolink/models/farmer_model.dart';

class AddVisitPage extends ConsumerStatefulWidget {
  const AddVisitPage({super.key});
  @override
  ConsumerState<AddVisitPage> createState() => _AddVisitPageState();
}

class _AddVisitPageState extends ConsumerState<AddVisitPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _fertilizerController = TextEditingController();
  final _feeController = TextEditingController();

  String? _selectedFarmerId;
  String? _selectedFarmerName;
  String? _selectedPlotId;
  DateTime _visitDate = DateTime.now();
  DateTime? _nextVisitDate;
  String _severity = 'low';
  bool _followUpRequired = false;
  final List<String> _selectedDiseases = [];
  final List<String> _medicines = [];
  final _medicineController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    _fertilizerController.dispose();
    _feeController.dispose();
    _medicineController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFarmerId == null) {
      AppHelpers.showError(context, 'Please select a farmer');
      return;
    }
    setState(() => _isLoading = true);

    try {
      final visit = VisitModel(
        visitId: '',
        farmerId: _selectedFarmerId!,
        farmerName: _selectedFarmerName ?? '',
        plotId: _selectedPlotId ?? '',
        doctorId: 'admin',
        visitDate: _visitDate,
        nextVisitDate: _nextVisitDate,
        diseaseObserved: _selectedDiseases,
        medicinesGiven: _medicines,
        fertilizerRecommendation: _fertilizerController.text.trim().isEmpty
            ? null : _fertilizerController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        severity: _severity,
        followUpRequired: _followUpRequired,
        consultationFee: double.tryParse(_feeController.text),
        createdAt: DateTime.now(),
      );

      await ref.read(firestoreServiceProvider).addVisit(visit);
      if (mounted) {
        AppHelpers.showSuccess(context, 'Visit added successfully');
        Navigator.pop(context);
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
        title: const Text('New Visit'),
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Farmer Selection
                  _section('Select Farmer', [
                    StreamBuilder<List<FarmerModel>>(
                      stream: ref.read(firestoreServiceProvider).streamFarmers(),
                      builder: (context, snap) {
                        final farmers = snap.data ?? [];
                        return DropdownButtonFormField<String>(
                          value: _selectedFarmerId,
                          decoration: const InputDecoration(
                            labelText: 'Farmer *',
                            prefixIcon: Icon(Icons.person_outlined),
                          ),
                          items: farmers.map((f) => DropdownMenuItem(
                            value: f.farmerId,
                            child: Text(f.farmerName),
                          )).toList(),
                          onChanged: (v) {
                            final farmer = farmers.firstWhere((f) => f.farmerId == v);
                            setState(() {
                              _selectedFarmerId = v;
                              _selectedFarmerName = farmer.farmerName;
                            });
                          },
                          validator: (v) => v == null ? 'Please select a farmer' : null,
                        );
                      },
                    ),
                  ]).animate().fadeIn().slideY(begin: 0.1),
                  const SizedBox(height: 20),

                  // Visit Details
                  _section('Visit Details', [
                    // Date picker
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context, initialDate: _visitDate,
                          firstDate: DateTime(2020), lastDate: DateTime(2030));
                        if (date != null) setState(() => _visitDate = date);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Visit Date *', prefixIcon: Icon(Icons.calendar_today_outlined)),
                        child: Text(AppHelpers.formatDate(_visitDate)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Severity
                    Text('Severity Level', style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: ['low', 'medium', 'high', 'critical'].map((s) {
                        final selected = _severity == s;
                        return ChoiceChip(
                          label: Text(s.toUpperCase()),
                          selected: selected,
                          selectedColor: AppHelpers.severityColor(s).withValues(alpha: 0.2),
                          onSelected: (_) => setState(() => _severity = s),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _feeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Consultation Fee (₹)', prefixIcon: Icon(Icons.currency_rupee_outlined)),
                    ),
                  ]).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),

                  // Disease & Treatment
                  _section('Disease & Treatment', [
                    Text('Diseases Observed', style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: AppConstants.commonDiseases.take(8).map((d) {
                        final selected = _selectedDiseases.contains(d);
                        return FilterChip(
                          label: Text(d, style: const TextStyle(fontSize: 12)),
                          selected: selected,
                          selectedColor: AppTheme.error.withValues(alpha: 0.15),
                          onSelected: (v) => setState(() {
                            v ? _selectedDiseases.add(d) : _selectedDiseases.remove(d);
                          }),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Medicines
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _medicineController,
                            decoration: const InputDecoration(
                              hintText: 'Add medicine...', prefixIcon: Icon(Icons.medication_outlined)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: () {
                            if (_medicineController.text.trim().isNotEmpty) {
                              setState(() {
                                _medicines.add(_medicineController.text.trim());
                                _medicineController.clear();
                              });
                            }
                          },
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ],
                    ),
                    if (_medicines.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6, runSpacing: 6,
                        children: _medicines.map((m) => Chip(
                          label: Text(m, style: const TextStyle(fontSize: 12)),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => setState(() => _medicines.remove(m)),
                        )).toList(),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fertilizerController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Fertilizer Recommendation',
                        prefixIcon: Icon(Icons.eco_outlined), alignLabelWithHint: true),
                    ),
                  ]).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),

                  // Notes & Follow-up
                  _section('Notes & Follow-up', [
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Visit Notes', prefixIcon: Icon(Icons.note_outlined), alignLabelWithHint: true),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Follow-up Required'),
                      subtitle: const Text('Schedule a follow-up visit'),
                      value: _followUpRequired,
                      onChanged: (v) => setState(() => _followUpRequired = v),
                    ),
                    if (_followUpRequired) ...[
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context, initialDate: DateTime.now().add(const Duration(days: 7)),
                            firstDate: DateTime.now(), lastDate: DateTime(2030));
                          if (date != null) setState(() => _nextVisitDate = date);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Next Visit Date', prefixIcon: Icon(Icons.event_outlined)),
                          child: Text(_nextVisitDate != null ? AppHelpers.formatDate(_nextVisitDate!) : 'Select date'),
                        ),
                      ),
                    ],
                  ]).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: 32),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSave,
                      child: _isLoading
                          ? const SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Save Visit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
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
