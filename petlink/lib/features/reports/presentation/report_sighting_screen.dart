import 'package:petlink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/pet_spacing.dart';
import '../../../design_system/buttons/pet_button.dart';
import '../providers/reports_providers.dart';

class ReportSightingScreen extends ConsumerStatefulWidget {
  final String reportId;

  const ReportSightingScreen({super.key, required this.reportId});

  @override
  ConsumerState<ReportSightingScreen> createState() =>
      _ReportSightingScreenState();
}

class _ReportSightingScreenState extends ConsumerState<ReportSightingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final report = await ref.read(reportByIdProvider(widget.reportId).future);
    if (report == null) return;
    setState(() => _loading = true);
    try {
      await ApiClient.instance.post(
        '/reports/${widget.reportId}/sightings',
        body: {
          'latitude': report.latitude,
          'longitude': report.longitude,
          'description': _descriptionController.text.trim(),
          'seenAt': DateTime.now().toIso8601String(),
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.sightingSent)));
        context.pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.sightingSendError(error.toString()))));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reportAsync = ref.watch(reportByIdProvider(widget.reportId));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportDetailReportSighting)),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text(l10n.sightingLoadError(error.toString()))),
        data: (report) => report == null
            ? Center(child: Text(l10n.reportNotFound))
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(PetSpacing.lg),
                  children: [
                    Text(
                      l10n.sightingPrompt(report.pet.name),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: PetSpacing.lg),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 6,
                      maxLength: 1000,
                      decoration: InputDecoration(
                        labelText: l10n.sightingDescription,
                        hintText: l10n.sightingDescriptionHint,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? l10n.sightingDescriptionRequired
                          : null,
                    ),
                    const SizedBox(height: PetSpacing.lg),
                    PetButton(
                      label: l10n.sightingSubmit,
                      isLoading: _loading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
