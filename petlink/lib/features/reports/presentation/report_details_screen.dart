import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/theme/pet_tokens.dart';
import '../../../shared/models/pet_report.dart';
import '../providers/report_draft_provider.dart';
import 'widgets/report_flow_stepper.dart';

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

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    final draft = ref.read(reportDraftProvider);
    _traitsController = TextEditingController(text: draft.traits);
    _descriptionController = TextEditingController(text: draft.description);
    if (draft.lastSeenAt != null) {
      _selectedDate = draft.lastSeenAt!;
      _selectedTime = TimeOfDay.fromDateTime(draft.lastSeenAt!);
    }
  }

  @override
  void dispose() {
    _traitsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveDetails() {
    final combinedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final notifier = ref.read(reportDraftProvider.notifier);
    notifier.setTraits(_traitsController.text.trim());
    notifier.setDescription(_descriptionController.text.trim());
    notifier.setLastSeenAt(combinedDateTime);
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? true) {
      _saveDetails();
      context.push('/report/new/review');
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: PetTokens.plum,
              onPrimary: Colors.white,
              surface: PetTokens.surface,
              onSurface: PetTokens.ink,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: PetTokens.plum,
              onPrimary: Colors.white,
              surface: PetTokens.surface,
              onSurface: PetTokens.ink,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${t.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(reportDraftProvider);
    final isLost = draft.reportType == ReportType.lost;

    return Scaffold(
      backgroundColor: PetTokens.bgOf(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Stepper oficial Paso 5 de 6
            ReportFlowStepper(
              currentStep: 5,
              stepTitle: l10n.reportDetailsTitle,
              onBack: () {
                _saveDetails();
                context.pop();
              },
            ),

            // Contenido escroleable
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  PetTokens.gutter,
                  12,
                  PetTokens.gutter,
                  110,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título según Paso5Detalles.dc.html
                      Text(
                        l10n.reportDetailsHeading,
                        style: PetTokens.displayThemed(context, 34),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.reportDetailsDescription,
                        style: PetTokens.bodyThemed(context, 15, color: PetTokens.mutedOf(context)),
                      ),
                      const SizedBox(height: 24),

                      // Estructura timeline con 3 nodos
                      _TimelineFormRow(
                        icon: PhosphorIconsBold.star,
                        nodeColor: PetTokens.plum,
                        isLast: false,
                        label: l10n.reportDetailsTraits,
                        child: TextFormField(
                          controller: _traitsController,
                          maxLines: 2,
                          style: PetTokens.bodyThemed(context, 15, color: PetTokens.inkOf(context)),
                          decoration: InputDecoration(
                            hintText: l10n.reportDetailsTraitsHint,
                            hintStyle: PetTokens.body(
                              14,
                              color: PetTokens.placeholder,
                            ),
                            filled: true,
                            fillColor: PetTokens.surfaceHigherOf(context),
                            contentPadding: const EdgeInsets.all(14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: PetTokens.borderOf(context),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: PetTokens.plumAccentOf(context),
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      _TimelineFormRow(
                        icon: PhosphorIconsBold.chatText,
                        nodeColor: PetTokens.plumAccentOf(context),
                        isLast: false,
                        label: isLost
                            ? l10n.reportDetailsLostQuestion
                            : l10n.reportDetailsFoundQuestion,
                        child: TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          style: PetTokens.bodyThemed(context, 15, color: PetTokens.inkOf(context)),
                          decoration: InputDecoration(
                            hintText: l10n.reportDetailsDescriptionHint,
                            hintStyle: PetTokens.body(
                              14,
                              color: PetTokens.placeholder,
                            ),
                            filled: true,
                            fillColor: PetTokens.surfaceHigherOf(context),
                            contentPadding: const EdgeInsets.all(14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: PetTokens.borderOf(context),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: PetTokens.plumAccentOf(context),
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      _TimelineFormRow(
                        icon: PhosphorIconsBold.clock,
                        nodeColor: PetTokens.clay,
                        isHighlight: true,
                        isLast: true,
                        label: isLost
                            ? l10n.reportDetailsDateLost
                            : l10n.reportDetailsDateFound,
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _pickDate,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: PetTokens.surfaceHigherOf(context),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: PetTokens.borderOf(context),
                                      width: 1.5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        PhosphorIconsRegular.calendar,
                                        size: 18,
                                        color: PetTokens.muted,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatDate(_selectedDate),
                                        style: PetTokens.bodyThemed(
                                          context,
                                          14,
                                          color: PetTokens.inkOf(context),
                                          weight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                onTap: _pickTime,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: PetTokens.surfaceHigherOf(context),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: PetTokens.borderOf(context),
                                      width: 1.5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        PhosphorIconsRegular.clock,
                                        size: 18,
                                        color: PetTokens.muted,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatTime(_selectedTime),
                                        style: PetTokens.bodyThemed(
                                          context,
                                          14,
                                          color: PetTokens.inkOf(context),
                                          weight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Botones inferiores (Volver + Revisar)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PetTokens.gutter,
                0,
                PetTokens.gutter,
                24,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      _saveDetails();
                      context.pop();
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 110,
                      height: 56,
                      decoration: BoxDecoration(
                        color: PetTokens.isDark(context)
                            ? PetTokens.surfaceHigherOf(context)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: PetTokens.isDark(context)
                              ? PetTokens.borderOf(context)
                              : PetTokens.plum,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        l10n.backAction,
                        style: PetTokens.body(
                          15,
                          color: PetTokens.isDark(context)
                              ? PetTokens.inkOf(context)
                              : PetTokens.plum,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _onContinue,
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: PetTokens.plum,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: PetTokens.shadowButton,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.continueAction,
                              style: PetTokens.body(
                                16,
                                color: Colors.white,
                                weight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// FILA TIMELINE CON NODO (Paso5Detalles.dc.html)
// -----------------------------------------------------------------------------
class _TimelineFormRow extends StatelessWidget {
  const _TimelineFormRow({
    required this.icon,
    required this.nodeColor,
    required this.label,
    required this.child,
    this.isHighlight = false,
    this.isLast = false,
  });

  final IconData icon;
  final Color nodeColor;
  final String label;
  final Widget child;
  final bool isHighlight;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!isLast)
          Positioned(
            left: 13,
            top: 24,
            bottom: -20,
            child: Container(
              width: 2,
              color: PetTokens.isDark(context) ? PetTokens.borderOf(context) : PetTokens.plum.withValues(alpha: 0.3),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 38),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: PetTokens.body(
                  14,
                  color: PetTokens.inkOf(context),
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isHighlight ? nodeColor : (PetTokens.isDark(context) ? PetTokens.surfaceHigherOf(context) : PetTokens.cream),
              shape: BoxShape.circle,
              border: Border.all(color: nodeColor, width: 2),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 14,
              color: isHighlight ? Colors.white : nodeColor,
            ),
          ),
        ),
      ],
    );
  }
}
