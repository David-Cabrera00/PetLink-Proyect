import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(reportDraftProvider);
    final isFound = draft.reportType == ReportType.found;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportPetInfoTitle),
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
                        // 1. Nombre
                        if (!isFound) ...[
                          PetInput(
                            label: l10n.reportPetInfoName,
                            hint: l10n.reportPetInfoNameHint,
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.requiredName;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: PetSpacing.md),
                        ] else ...[
                          PetInput(
                            label: l10n.reportPetInfoNameOptional,
                            hint: l10n.reportPetInfoNameHint,
                            controller: _nameController,
                          ),
                          const SizedBox(height: PetSpacing.md),
                        ],

                        // 2. Especie con selector rápido
                        Text(
                          l10n.reportPetInfoSpecies,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: PetSpacing.xs),
                        Row(
                          children: [
                            _buildChoiceChip(
                              label: 'Perro',
                              icon: Icons.pets,
                              selectedColor: const Color(0xFFE3A07F),
                              isSelected:
                                  _speciesController.text.toLowerCase() ==
                                  'perro',
                              onSelected: () => setState(
                                () => _speciesController.text = 'Perro',
                              ),
                            ),
                            const SizedBox(width: PetSpacing.sm),
                            _buildChoiceChip(
                              label: 'Gato',
                              icon: Icons.pets_outlined,
                              selectedColor: const Color(0xFF9D83A7),
                              isSelected:
                                  _speciesController.text.toLowerCase() ==
                                  'gato',
                              onSelected: () => setState(
                                () => _speciesController.text = 'Gato',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: PetSpacing.md),

                        // 3. Raza
                        PetInput(
                          label: l10n.reportPetInfoBreed,
                          hint: l10n.reportPetInfoBreedHint,
                          controller: _breedController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.requiredBreed;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: PetSpacing.md),

                        // 4. Sexo con selector rápido
                        Text(
                          l10n.reportPetInfoSex,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: PetSpacing.xs),
                        Row(
                          children: [
                            _buildChoiceChip(
                              label: 'Macho',
                              icon: Icons.male,
                              selectedColor: const Color(0xFF7D9BB2),
                              isSelected:
                                  _sexController.text.toLowerCase() == 'macho',
                              onSelected: () =>
                                  setState(() => _sexController.text = 'Macho'),
                            ),
                            const SizedBox(width: PetSpacing.sm),
                            _buildChoiceChip(
                              label: 'Hembra',
                              icon: Icons.female,
                              selectedColor: const Color(0xFFD98C9A),
                              isSelected:
                                  _sexController.text.toLowerCase() == 'hembra',
                              onSelected: () => setState(
                                () => _sexController.text = 'Hembra',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: PetSpacing.md),

                        // 5. Tamaño con selector rápido
                        Text(
                          l10n.reportPetInfoSize,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: PetSpacing.xs),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildChoiceChip(
                                label: 'Pequeño',
                                isSelected:
                                    _sizeController.text.toLowerCase() ==
                                    'pequeño',
                                onSelected: () => setState(
                                  () => _sizeController.text = 'Pequeño',
                                ),
                              ),
                              const SizedBox(width: PetSpacing.sm),
                              _buildChoiceChip(
                                label: 'Mediano',
                                isSelected:
                                    _sizeController.text.toLowerCase() ==
                                    'mediano',
                                onSelected: () => setState(
                                  () => _sizeController.text = 'Mediano',
                                ),
                              ),
                              const SizedBox(width: PetSpacing.sm),
                              _buildChoiceChip(
                                label: 'Grande',
                                isSelected:
                                    _sizeController.text.toLowerCase() ==
                                    'grande',
                                onSelected: () => setState(
                                  () => _sizeController.text = 'Grande',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: PetSpacing.md),

                        // 6. Edad y Color
                        Row(
                          children: [
                            Expanded(
                              child: PetInput(
                                label: l10n.reportPetInfoAge,
                                hint: l10n.reportPetInfoAgeHint,
                                controller: _ageController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.requiredField;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: PetSpacing.md),
                            Expanded(
                              child: PetInput(
                                label: l10n.reportPetInfoColor,
                                hint: l10n.reportPetInfoColorHint,
                                controller: _colorController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.requiredField;
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

  Widget _buildChoiceChip({
    required String label,
    IconData? icon,
    Color? selectedColor,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    final cs = Theme.of(context).colorScheme;
    final activeColor = selectedColor ?? cs.primary;
    final activeForeground = activeColor.computeLuminance() > 0.45
        ? cs.onSurface
        : Colors.white;

    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: PetSpacing.md,
          vertical: PetSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? activeForeground : cs.onSurfaceVariant,
              ),
              const SizedBox(width: PetSpacing.xs),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? activeForeground : cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.go('/report/new'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: PetSpacing.md),
            ),
            child: Text(l10n.backAction),
          ),
        ),
        const SizedBox(width: PetSpacing.md),
        Expanded(
          child: PetButton(
            label: l10n.continueAction,
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
