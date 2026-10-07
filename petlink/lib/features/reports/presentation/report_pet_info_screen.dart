import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pet_spacing.dart';
import '../../../design_system/buttons/pet_button.dart';
import '../../../design_system/inputs/pet_input.dart';
import '../../../shared/models/pet_report.dart';
import '../../../shared/widgets/step_indicator.dart';
import '../providers/report_draft_provider.dart';

class ReportPetInfoScreen extends ConsumerStatefulWidget {
  const ReportPetInfoScreen({super.key});

  @override
  ConsumerState<ReportPetInfoScreen> createState() =>
      _ReportPetInfoScreenState();
}

class _ReportPetInfoScreenState extends ConsumerState<ReportPetInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _speciesController;
  late final TextEditingController _breedController;
  late final TextEditingController _sexController;
  late final TextEditingController _ageController;
  late final TextEditingController _sizeController;
  late final TextEditingController _colorController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(reportDraftProvider);
    _nameController = TextEditingController(text: draft.name);
    _speciesController = TextEditingController(text: draft.species);
    _breedController = TextEditingController(text: draft.breed);
    _sexController = TextEditingController(text: draft.sex);
    _ageController = TextEditingController(text: draft.age);
    _sizeController = TextEditingController(text: draft.size);
    _colorController = TextEditingController(text: draft.color);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _sexController.dispose();
    _ageController.dispose();
    _sizeController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(reportDraftProvider);
    final isFound = draft.reportType == ReportType.found;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos de la mascota'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/report/new'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(PetSpacing.lg),
          child: Column(
            children: [
              const StepIndicator(current: 2, total: 6),
              const SizedBox(height: PetSpacing.xl),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isFound) ...[
                          PetInput(
                            label: 'Nombre',
                            hint: 'Ej. Luna',
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El nombre es obligatorio';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: PetSpacing.md),
                        ],
                        PetInput(
                          label: isFound ? 'Nombre (opcional)' : 'Especie',
                          hint: isFound ? 'Ej. Luna' : 'Ej. Perro',
                          controller: isFound
                              ? _nameController
                              : _speciesController,
                          validator: isFound
                              ? null
                              : (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'La especie es obligatoria';
                                  }
                                  return null;
                                },
                        ),
                        const SizedBox(height: PetSpacing.md),
                        PetInput(
                          label: 'Raza',
                          hint: 'Ej. Golden Retriever',
                          controller: _breedController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'La raza es obligatoria';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: PetSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: PetInput(
                                label: 'Sexo',
                                hint: 'Macho / Hembra',
                                controller: _sexController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Requerido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: PetSpacing.md),
                            Expanded(
                              child: PetInput(
                                label: 'Edad',
                                hint: 'Ej. 4 años',
                                controller: _ageController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Requerido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: PetSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: PetInput(
                                label: 'Tamaño',
                                hint: 'Pequeño / Mediano / Grande',
                                controller: _sizeController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Requerido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: PetSpacing.md),
                            Expanded(
                              child: PetInput(
                                label: 'Color',
                                hint: 'Ej. Dorado',
                                controller: _colorController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Requerido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: PetSpacing.lg),
              _buildActionButtons(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.go('/report/new'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: PetSpacing.md),
            ),
            child: const Text('Volver'),
          ),
        ),
        const SizedBox(width: PetSpacing.md),
        Expanded(
          child: PetButton(
            label: 'Continuar',
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _saveDraft(ref);
                context.go('/report/new/photos');
              }
            },
            icon: Icons.arrow_forward,
          ),
        ),
      ],
    );
  }

  void _saveDraft(WidgetRef ref) {
    final notifier = ref.read(reportDraftProvider.notifier);
    notifier.setName(_nameController.text.trim());
    notifier.setSpecies(_speciesController.text.trim());
    notifier.setBreed(_breedController.text.trim());
    notifier.setSex(_sexController.text.trim());
    notifier.setAge(_ageController.text.trim());
    notifier.setSize(_sizeController.text.trim());
    notifier.setColor(_colorController.text.trim());
  }
}
