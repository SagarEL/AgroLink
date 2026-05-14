import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
import '../../models/farmer.dart';
import '../../widgets/avatar.dart';
import '../../widgets/surface_card.dart';
import '../auth/auth_controller.dart';
import 'farmer_repository.dart';

class FarmerFormPage extends ConsumerStatefulWidget {
  const FarmerFormPage({super.key, this.farmerId});
  final String? farmerId;
  @override
  ConsumerState<FarmerFormPage> createState() => _FarmerFormPageState();
}

class _FarmerFormPageState extends ConsumerState<FarmerFormPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _altPhone = TextEditingController();
  final _email = TextEditingController();
  final _village = TextEditingController();
  final _address = TextEditingController();
  final _notes = TextEditingController();
  Uint8List? _newImage;
  String? _existingImage;
  bool _busy = false;
  Farmer? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.farmerId != null) _load();
  }

  Future<void> _load() async {
    final repo = ref.read(farmerRepositoryProvider);
    final farmer = await repo.watchOne(widget.farmerId!).first;
    if (farmer == null || !mounted) return;
    _existing = farmer;
    _name.text = farmer.name;
    _phone.text = farmer.phone;
    _altPhone.text = farmer.altPhone ?? '';
    _email.text = farmer.email ?? '';
    _village.text = farmer.village;
    _address.text = farmer.address;
    _notes.text = farmer.notes ?? '';
    _existingImage = farmer.profileImage;
    setState(() {});
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _altPhone, _email, _village, _address, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _newImage = bytes);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      final repo = ref.read(farmerRepositoryProvider);
      final base = _existing ??
          Farmer(
            id: '',
            name: _name.text.trim(),
            phone: _phone.text.trim(),
            village: _village.text.trim(),
            address: _address.text.trim(),
            createdBy: user?.uid ?? 'unknown',
            createdAt: DateTime.now(),
          );
      final updated = base.copyWith(
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        altPhone: _altPhone.text.trim().isEmpty ? null : _altPhone.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        village: _village.text.trim(),
        address: _address.text.trim(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      );
      await repo.upsert(updated, newProfileImage: _newImage);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Farmer saved')),
        );
        context.go(AppRoutes.farmers);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.farmerId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit farmer' : 'Add farmer'),
        actions: [
          TextButton(
            onPressed: _busy ? null : _save,
            child: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
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
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                child: _newImage != null
                                    ? Image.memory(_newImage!, width: 96, height: 96, fit: BoxFit.cover)
                                    : Avatar(name: _name.text.isEmpty ? 'New' : _name.text,
                                        imageUrl: _existingImage, size: 96),
                              ),
                              Positioned(
                                right: 4,
                                bottom: 4,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Profile photo',
                                  style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                'Square JPG/PNG, up to 5 MB. Visible inside the farmer profile and on visit cards.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              OutlinedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.image_outlined, size: 16),
                                label: const Text('Upload photo'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contact', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _name,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(labelText: 'Full name'),
                          validator: (v) => Validators.required(v, field: 'Name'),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _phone,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(labelText: 'Phone'),
                                validator: Validators.phone,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: TextFormField(
                                controller: _altPhone,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(labelText: 'Alt phone (optional)'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Email (optional)'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Address', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _village,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(labelText: 'Village / town'),
                          validator: (v) => Validators.required(v, field: 'Village'),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _address,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(labelText: 'Address / landmarks'),
                          validator: (v) => Validators.required(v, field: 'Address'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notes', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _notes,
                          minLines: 3,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            labelText: 'Internal notes (optional)',
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
                    label: Text(isEdit ? 'Save changes' : 'Add farmer'),
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
