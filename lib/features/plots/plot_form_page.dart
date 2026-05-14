import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_constants.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
import '../../models/farmer.dart';
import '../../models/plot.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/surface_card.dart';
import '../farmers/farmer_repository.dart';
import 'plot_repository.dart';

class PlotFormPage extends ConsumerStatefulWidget {
  const PlotFormPage({super.key, this.plotId, this.presetFarmerId});
  final String? plotId;
  final String? presetFarmerId;

  @override
  ConsumerState<PlotFormPage> createState() => _PlotFormPageState();
}

class _PlotFormPageState extends ConsumerState<PlotFormPage> {
  final _form = GlobalKey<FormState>();
  final _label = TextEditingController();
  final _acreage = TextEditingController();
  final _variety = TextEditingController();
  final _notes = TextEditingController();
  String? _farmerId;
  String _cropType = 'Pomegranate';
  DiseaseStatus _disease = DiseaseStatus.healthy;
  PriorityLevel _priority = PriorityLevel.low;
  DateTime? _plantingDate;
  Plot? _existing;
  bool _busy = false;
  final List<Uint8List> _newImages = [];

  @override
  void initState() {
    super.initState();
    _farmerId = widget.presetFarmerId;
    if (widget.plotId != null) _load();
  }

  Future<void> _load() async {
    final repo = ref.read(plotRepositoryProvider);
    final plot = await repo.watchOne(widget.plotId!).first;
    if (plot == null || !mounted) return;
    _existing = plot;
    _farmerId = plot.farmerId;
    _label.text = plot.label;
    _acreage.text = plot.acreage.toString();
    _variety.text = plot.variety ?? '';
    _cropType = plot.cropType;
    _disease = plot.diseaseStatus;
    _priority = plot.priorityLevel;
    _plantingDate = plot.plantingDate;
    _notes.text = plot.notes ?? '';
    setState(() {});
  }

  @override
  void dispose() {
    for (final c in [_label, _acreage, _variety, _notes]) c.dispose();
    super.dispose();
  }

  Future<void> _pickPlantingDate() async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
      initialDate: _plantingDate ?? DateTime.now(),
    );
    if (d != null) setState(() => _plantingDate = d);
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 80, maxWidth: 1600);
    for (final f in files) {
      final bytes = await f.readAsBytes();
      _newImages.add(bytes);
    }
    setState(() {});
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _farmerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a farmer first')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final repo = ref.read(plotRepositoryProvider);
      final base = _existing ??
          Plot(
            id: '',
            farmerId: _farmerId!,
            label: _label.text.trim(),
            cropType: _cropType,
            acreage: double.tryParse(_acreage.text) ?? 0,
            createdAt: DateTime.now(),
          );
      final updated = base.copyWith(
        farmerId: _farmerId,
        label: _label.text.trim(),
        cropType: _cropType,
        variety: _variety.text.trim().isEmpty ? null : _variety.text.trim(),
        acreage: double.tryParse(_acreage.text) ?? 0,
        diseaseStatus: _disease,
        priorityLevel: _priority,
        plantingDate: _plantingDate,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      );
      await repo.upsert(updated, newImages: _newImages);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plot saved')),
        );
        context.go(AppRoutes.plots);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmers = ref.watch(farmersStreamProvider(const FarmerFilter(limit: 500)));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plotId == null ? 'Add plot' : 'Edit plot'),
        actions: [
          TextButton(
            onPressed: _busy ? null : _save,
            child: _busy
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Plot identity', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.md),
                        farmers.when(
                          loading: () => const Skeleton(height: 48),
                          error: (e, _) => Text('$e'),
                          data: (list) => _FarmerPicker(
                            farmers: list,
                            selectedId: _farmerId,
                            onChanged: (id) => setState(() => _farmerId = id),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _label,
                          decoration: const InputDecoration(labelText: 'Plot label (e.g. "Back field")'),
                          validator: (v) => Validators.required(v, field: 'Label'),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownMenu<String>(
                                initialSelection: _cropType,
                                label: const Text('Crop'),
                                width: double.infinity,
                                onSelected: (v) => setState(() => _cropType = v ?? _cropType),
                                dropdownMenuEntries: [
                                  for (final c in AppConstants.commonCrops)
                                    DropdownMenuEntry(value: c, label: c),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: TextFormField(
                                controller: _variety,
                                decoration: const InputDecoration(labelText: 'Variety (optional)'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _acreage,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Acreage',
                                  suffixText: 'acres',
                                ),
                                validator: (v) => Validators.positiveNumber(v, field: 'Acreage'),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: InkWell(
                                onTap: _pickPlantingDate,
                                child: InputDecorator(
                                  decoration: const InputDecoration(labelText: 'Planting date'),
                                  child: Text(
                                    _plantingDate == null
                                        ? 'Select date'
                                        : '${_plantingDate!.day}/${_plantingDate!.month}/${_plantingDate!.year}',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final s in DiseaseStatus.values)
                              ChoiceChip(
                                label: Text(s.label),
                                selected: _disease == s,
                                onSelected: (_) => setState(() => _disease = s),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('Priority', style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final p in PriorityLevel.values)
                              ChoiceChip(
                                label: Text(p.label),
                                selected: _priority == p,
                                onSelected: (_) => setState(() => _priority = p),
                                selectedColor: AppColors.primarySoft,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('Photos', style: Theme.of(context).textTheme.titleMedium),
                            ),
                            OutlinedButton.icon(
                              onPressed: _pickImages,
                              icon: const Icon(Icons.add_a_photo_outlined, size: 16),
                              label: const Text('Add'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (_newImages.isEmpty)
                          Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'No photos added yet',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          )
                        else
                          SizedBox(
                            height: 96,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _newImages.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (_, i) => ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                child: Image.memory(_newImages[i], width: 96, height: 96, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _notes,
                          minLines: 3,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            labelText: 'Notes (optional)',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  FilledButton.icon(
                    onPressed: _busy ? null : _save,
                    icon: const Icon(Icons.check_rounded),
                    label: Text(widget.plotId == null ? 'Add plot' : 'Save changes'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FarmerPicker extends StatelessWidget {
  const _FarmerPicker({required this.farmers, required this.selectedId, required this.onChanged});
  final List<Farmer> farmers;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String?>(
      initialSelection: selectedId,
      label: const Text('Farmer'),
      width: double.infinity,
      onSelected: onChanged,
      dropdownMenuEntries: [
        for (final f in farmers)
          DropdownMenuEntry(value: f.id, label: '${f.name} · ${f.village}'),
      ],
    );
  }
}
