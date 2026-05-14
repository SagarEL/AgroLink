import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../models/farmer.dart';
import '../../models/plot.dart';
import '../../models/visit.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/surface_card.dart';
import '../auth/auth_controller.dart';
import '../farmers/farmer_repository.dart';
import '../plots/plot_repository.dart';
import 'visit_repository.dart';

class VisitFormPage extends ConsumerStatefulWidget {
  const VisitFormPage({super.key, this.visitId, this.presetFarmerId, this.presetPlotId});
  final String? visitId;
  final String? presetFarmerId;
  final String? presetPlotId;
  @override
  ConsumerState<VisitFormPage> createState() => _VisitFormPageState();
}

class _VisitFormPageState extends ConsumerState<VisitFormPage> {
  final _form = GlobalKey<FormState>();
  String? _farmerId;
  String? _plotId;
  DateTime _visitDate = DateTime.now();
  DateTime? _nextVisitDate;
  PriorityLevel _severity = PriorityLevel.low;
  VisitStatus _status = VisitStatus.planned;
  bool _followUp = false;
  final List<String> _diseases = [];
  final List<_MedicineRow> _medicineRows = [];
  final _diseaseCtrl = TextEditingController();
  final _fertilizer = TextEditingController();
  final _notes = TextEditingController();
  final _fee = TextEditingController();
  final List<Uint8List> _newPhotos = [];
  Visit? _existing;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _farmerId = widget.presetFarmerId;
    _plotId = widget.presetPlotId;
    if (widget.visitId != null) _load();
  }

  Future<void> _load() async {
    final repo = ref.read(visitRepositoryProvider);
    final v = await repo.watchOne(widget.visitId!).first;
    if (v == null || !mounted) return;
    _existing = v;
    _farmerId = v.farmerId;
    _plotId = v.plotId;
    _visitDate = v.visitDate;
    _nextVisitDate = v.nextVisitDate;
    _severity = v.severity;
    _status = v.status;
    _followUp = v.followUpRequired;
    _diseases.addAll(v.diseasesObserved);
    for (final m in v.medicines) {
      _medicineRows.add(_MedicineRow.from(m));
    }
    _fertilizer.text = v.fertilizerRecommendation ?? '';
    _notes.text = v.notes ?? '';
    _fee.text = v.feeCharged?.toString() ?? '';
    setState(() {});
  }

  @override
  void dispose() {
    _diseaseCtrl.dispose();
    _fertilizer.dispose();
    _notes.dispose();
    _fee.dispose();
    for (final r in _medicineRows) r.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 80, maxWidth: 1600);
    for (final f in files) {
      _newPhotos.add(await f.readAsBytes());
    }
    setState(() {});
  }

  Future<void> _capturePhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (file == null) return;
    _newPhotos.add(await file.readAsBytes());
    setState(() {});
  }

  Future<void> _pickVisitDate() async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _visitDate,
    );
    if (d == null) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_visitDate));
    setState(() {
      _visitDate = DateTime(d.year, d.month, d.day, t?.hour ?? 9, t?.minute ?? 0);
    });
  }

  Future<void> _pickNextVisit() async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _nextVisitDate ?? DateTime.now().add(const Duration(days: 14)),
    );
    if (d != null) setState(() => _nextVisitDate = d);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_farmerId == null || _plotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose the farmer and plot for this visit')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      final farmer = await ref.read(farmerByIdProvider(_farmerId!).future);
      final plot = await ref.read(plotByIdProvider(_plotId!).future);
      final repo = ref.read(visitRepositoryProvider);
      final base = _existing ??
          Visit(
            id: '',
            farmerId: _farmerId!,
            plotId: _plotId!,
            doctorId: user?.uid ?? 'unknown',
            visitDate: _visitDate,
            createdAt: DateTime.now(),
          );
      final updated = base.copyWith(
        farmerId: _farmerId,
        plotId: _plotId,
        visitDate: _visitDate,
        nextVisitDate: _nextVisitDate,
        diseasesObserved: _diseases,
        medicines: _medicineRows.map((r) => r.toEntry()).toList(),
        fertilizerRecommendation: _fertilizer.text.trim().isEmpty ? null : _fertilizer.text.trim(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        severity: _severity,
        status: _status,
        followUpRequired: _followUp,
        feeCharged: double.tryParse(_fee.text),
        farmerName: farmer?.name,
        plotLabel: plot?.label,
        village: farmer?.village ?? plot?.location?.village,
      );
      await repo.upsert(updated, newPhotos: _newPhotos);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visit saved')),
        );
        context.go(AppRoutes.visits);
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
    final plotsAsync =
        _farmerId == null ? const AsyncValue<List<Plot>>.data([]) : ref.watch(plotsForFarmerProvider(_farmerId!));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.visitId == null ? 'New visit' : 'Edit visit'),
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
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _whoCard(farmers, plotsAsync),
                  const SizedBox(height: AppSpacing.lg),
                  _whenCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _findingsCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _treatmentCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _attachmentsCard(),
                  const SizedBox(height: AppSpacing.xxl),
                  FilledButton.icon(
                    onPressed: _busy ? null : _save,
                    icon: const Icon(Icons.check_rounded),
                    label: Text(widget.visitId == null ? 'Save visit' : 'Save changes'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _whoCard(AsyncValue<List<Farmer>> farmers, AsyncValue<List<Plot>> plotsAsync) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Who', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          farmers.when(
            loading: () => const Skeleton(height: 48),
            error: (e, _) => Text('$e'),
            data: (list) => DropdownMenu<String?>(
              initialSelection: _farmerId,
              label: const Text('Farmer'),
              width: double.infinity,
              onSelected: (id) => setState(() {
                _farmerId = id;
                _plotId = null;
              }),
              dropdownMenuEntries: [
                for (final f in list)
                  DropdownMenuEntry(value: f.id, label: '${f.name} · ${f.village}'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          plotsAsync.when(
            loading: () => const Skeleton(height: 48),
            error: (e, _) => Text('$e'),
            data: (list) => DropdownMenu<String?>(
              initialSelection: _plotId,
              label: const Text('Plot'),
              width: double.infinity,
              onSelected: (id) => setState(() => _plotId = id),
              dropdownMenuEntries: [
                for (final p in list)
                  DropdownMenuEntry(value: p.id, label: '${p.label} · ${p.cropType}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _whenCard() {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('When', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _pickVisitDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Visit date & time'),
                    child: Text(Formatters.dateTime(_visitDate)),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: InkWell(
                  onTap: _pickNextVisit,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Next visit (optional)'),
                    child: Text(
                      _nextVisitDate == null ? 'Schedule later' : Formatters.date(_nextVisitDate),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 8,
            children: [
              for (final s in VisitStatus.values)
                ChoiceChip(
                  label: Text(s.label),
                  selected: _status == s,
                  onSelected: (_) => setState(() => _status = s),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _findingsCard() {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Findings', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _diseaseCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Add disease / observation',
                    prefixIcon: Icon(Icons.bug_report_outlined),
                  ),
                  onSubmitted: (v) {
                    final t = v.trim();
                    if (t.isNotEmpty) setState(() {
                      _diseases.add(t);
                      _diseaseCtrl.clear();
                    });
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton.tonal(
                onPressed: () {
                  final t = _diseaseCtrl.text.trim();
                  if (t.isNotEmpty) {
                    setState(() {
                      _diseases.add(t);
                      _diseaseCtrl.clear();
                    });
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
          if (_diseases.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < _diseases.length; i++)
                  InputChip(
                    label: Text(_diseases[i]),
                    onDeleted: () => setState(() => _diseases.removeAt(i)),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text('Severity', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              for (final p in PriorityLevel.values)
                ChoiceChip(
                  label: Text(p.label),
                  selected: _severity == p,
                  onSelected: (_) => setState(() => _severity = p),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _followUp,
            onChanged: (v) => setState(() => _followUp = v),
            title: const Text('Schedule a follow-up'),
            subtitle: const Text('We will create a reminder notification automatically.'),
          ),
        ],
      ),
    );
  }

  Widget _treatmentCard() {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Treatment plan', style: Theme.of(context).textTheme.titleMedium)),
              TextButton.icon(
                onPressed: () => setState(() => _medicineRows.add(_MedicineRow.empty())),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add medicine'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (_medicineRows.isEmpty)
            Text(
              'No medicines added.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          for (var i = 0; i < _medicineRows.length; i++) ...[
            _MedicineEditor(
              row: _medicineRows[i],
              onDelete: () => setState(() {
                _medicineRows.removeAt(i).dispose();
              }),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _fertilizer,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Fertilizer recommendation',
              prefixIcon: Icon(Icons.local_florist_outlined),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _fee,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Fee charged (optional)',
              prefixIcon: Icon(Icons.currency_rupee_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _attachmentsCard() {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Photos & notes', style: Theme.of(context).textTheme.titleMedium)),
              IconButton(
                tooltip: 'Camera',
                icon: const Icon(Icons.photo_camera_outlined),
                onPressed: _capturePhoto,
              ),
              IconButton(
                tooltip: 'Gallery',
                icon: const Icon(Icons.photo_library_outlined),
                onPressed: _pickPhotos,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_newPhotos.isNotEmpty)
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _newPhotos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Image.memory(_newPhotos[i], width: 96, height: 96, fit: BoxFit.cover),
                    ),
                    Positioned(
                      right: 2,
                      top: 2,
                      child: GestureDetector(
                        onTap: () => setState(() => _newPhotos.removeAt(i)),
                        child: const CircleAvatar(
                          radius: 11,
                          backgroundColor: AppColors.overlay,
                          child: Icon(Icons.close_rounded, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _notes,
            minLines: 3,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Notes',
              prefixIcon: Icon(Icons.notes_outlined),
              alignLabelWithHint: true,
            ),
            validator: (v) => Validators.minLength(v, 4, field: 'Notes'),
          ),
        ],
      ),
    );
  }
}

class _MedicineRow {
  _MedicineRow({TextEditingController? name, TextEditingController? dosage, TextEditingController? freq, TextEditingController? notes})
      : name = name ?? TextEditingController(),
        dosage = dosage ?? TextEditingController(),
        frequency = freq ?? TextEditingController(),
        notes = notes ?? TextEditingController();

  final TextEditingController name;
  final TextEditingController dosage;
  final TextEditingController frequency;
  final TextEditingController notes;

  factory _MedicineRow.empty() => _MedicineRow();
  factory _MedicineRow.from(MedicineEntry m) => _MedicineRow(
        name: TextEditingController(text: m.name),
        dosage: TextEditingController(text: m.dosage),
        freq: TextEditingController(text: m.frequency ?? ''),
        notes: TextEditingController(text: m.notes ?? ''),
      );

  MedicineEntry toEntry() => MedicineEntry(
        name: name.text.trim(),
        dosage: dosage.text.trim(),
        frequency: frequency.text.trim().isEmpty ? null : frequency.text.trim(),
        notes: notes.text.trim().isEmpty ? null : notes.text.trim(),
      );

  void dispose() {
    name.dispose();
    dosage.dispose();
    frequency.dispose();
    notes.dispose();
  }
}

class _MedicineEditor extends StatelessWidget {
  const _MedicineEditor({required this.row, required this.onDelete});
  final _MedicineRow row;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: row.name,
                  decoration: const InputDecoration(labelText: 'Medicine'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: row.dosage,
                  decoration: const InputDecoration(labelText: 'Dosage'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: row.frequency,
                  decoration: const InputDecoration(labelText: 'Frequency (e.g. every 7 days)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: row.notes,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
