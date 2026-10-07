import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pet_colors.dart';
import '../../../core/theme/pet_spacing.dart';
import '../../../core/theme/pet_radius.dart';
import '../../../design_system/buttons/pet_button.dart';
import '../../../design_system/inputs/pet_input.dart';
import '../../../shared/models/pet_report.dart';
import '../../../shared/widgets/step_indicator.dart';
import '../providers/report_draft_provider.dart';

class ReportDetailsScreen extends ConsumerStatefulWidget {
  const ReportDetailsScreen({super.key});

  @override
  ConsumerState<ReportDetailsScreen> createState() =>
      _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends ConsumerState<ReportDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _traitsController;
  late final TextEditingController _descriptionController;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(reportDraftProvider);
    _traitsController = TextEditingController(text: draft.traits);
    _descriptionController = TextEditingController(text: draft.description);
    _selectedDateTime = draft.lastSeenAt;
  }

  @override
  void dispose() {
    _traitsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(reportDraftProvider);
    final isLost = draft.reportType == ReportType.lost;
    final isFound = draft.reportType == ReportType.found;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/report/new/location'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(PetSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepIndicator(current: 5, total: 6),
              const SizedBox(height: PetSpacing.xl),
              Text(
                'Detalles adicionales',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: PetSpacing.xs),
              Text(
                'Información que ayudará a identificar a la mascota.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: PetSpacing.xl),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PetInput(
                          label: 'Señas particulares',
                          hint:
                              'Ej. Mancha blanca en el pecho, collar marrón...',
                          controller: _traitsController,
                          maxLines: 3,
                        ),
                        const SizedBox(height: PetSpacing.md),
                        PetInput(
                          label: isLost
                              ? '¿Qué ocurrió?'
                              : 'Cuéntanos cómo la encontraste',
                          hint: 'Describe las circunstancias...',
                          controller: _descriptionController,
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Este campo es obligatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: PetSpacing.md),
                        _buildDateTimePicker(context, ref, isLost),
                        const SizedBox(height: PetSpacing.md),
                        if (isFound) _buildIsPetWithFinder(context, ref),
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

  Widget _buildDateTimePicker(
    BuildContext context,
    WidgetRef ref,
    bool isLost,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isLost
              ? '¿Cuándo fue vista por última vez?'
              : '¿Cuándo la encontraste?',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 8),
      PetInput(
        label: isLost
            ? '¿Cuándo fue vista por última vez?'
            : '¿Cuándo la encontraste?',
        hint: 'Seleccionar fecha y hora',
        readOnly: true,
        onTap: () => _pickDateTime(context, ref),
        controller: TextEditingController(
          text: _selectedDateTime != null
              ? _formatDateTime(_selectedDateTime!)
              : '',
        ),
      ),
      if (_selectedDateTime == null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Selecciona la fecha y hora',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    );
  }

  Widget _buildIsPetWithFinder(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(reportDraftProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿La mascota está contigo?',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: PetColors.textSecondary,
          ),
        ),
        const SizedBox(height: PetSpacing.md),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => ref
                    .read(reportDraftProvider.notifier)
                    .setIsPetWithFinder(true),
                child: _buildOptionCard(
                  context,
                  'Sí',
                  Icons.check_circle,
                  draft.isPetWithFinder == true,
                ),
              ),
            ),
            const SizedBox(width: PetSpacing.md),
            Expanded(
              child: GestureDetector(
                onTap: () => ref
                    .read(reportDraftProvider.notifier)
                    .setIsPetWithFinder(false),
                child: _buildOptionCard(
                  context,
                  'No',
                  Icons.cancel,
                  draft.isPetWithFinder == false,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String label,
    IconData icon,
    bool selected,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: PetSpacing.md),
      decoration: BoxDecoration(
        color: selected ? PetColors.primarySoft : PetColors.surface,
        borderRadius: PetRadius.lgAll,
        border: Border.all(
          color: selected ? PetColors.primary : PetColors.border,
          width: selected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: selected ? PetColors.primary : PetColors.textSecondary,
            size: 28,
          ),
          const SizedBox(height: PetSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? PetColors.primary : PetColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.go('/report/new/location'),
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
                if (_selectedDateTime == null) {
                  _showError(context, 'Selecciona la fecha y hora');
                  return;
                }
                _saveDetails(ref);
                context.go('/report/new/review');
              }
            },
            icon: Icons.arrow_forward,
          ),
        ),
      ],
    );
  }

  void _saveDetails(WidgetRef ref) {
    final notifier = ref.read(reportDraftProvider.notifier);
    notifier.setTraits(_traitsController.text.trim());
    notifier.setDescription(_descriptionController.text.trim());
    notifier.setLastSeenAt(_selectedDateTime!);
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDateTime(BuildContext context, WidgetRef ref) async {
    final initialDate = _selectedDateTime ?? DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (time != null && context.mounted) {
        final newDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        ref.read(reportDraftProvider.notifier).setLastSeenAt(newDateTime);
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: PetColors.lost,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: PetRadius.lgAll),
      ),
    );
  }
}
