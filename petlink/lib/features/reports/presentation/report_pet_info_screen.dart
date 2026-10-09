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
                        ],
                        PetInput(
                          label: isFound
                              ? l10n.reportPetInfoNameOptional
                              : l10n.reportPetInfoSpecies,
                          hint: isFound
                              ? l10n.reportPetInfoNameHint
                              : l10n.reportPetInfoSpeciesHint,
                          controller: isFound
                              ? _nameController
                              : _speciesController,
                          validator: isFound
                              ? null
                              : (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.requiredSpecies;
                                  }
                                  return null;
                                },
                        ),
                        const SizedBox(height: PetSpacing.md),
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
                        Row(
                          children: [
                            Expanded(
                              child: PetInput(
                                label: l10n.reportPetInfoSex,
                                hint: l10n.reportPetInfoSexHint,
                                controller: _sexController,
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
                          ],
                        ),
                        const SizedBox(height: PetSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: PetInput(
                                label: l10n.reportPetInfoSize,
                                hint: l10n.reportPetInfoSizeHint,
                                controller: _sizeController,
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
