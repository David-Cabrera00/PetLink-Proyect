import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/theme/pet_colors.dart';
import '../../../core/theme/pet_spacing.dart';
import '../../../core/theme/pet_radius.dart';
import '../../../design_system/buttons/pet_button.dart';
import '../../../design_system/inputs/pet_input.dart';
import '../../../shared/models/pet_report.dart';
import '../../../shared/widgets/step_indicator.dart';
import '../providers/report_draft_provider.dart';

class ReportLocationScreen extends ConsumerStatefulWidget {
  const ReportLocationScreen({super.key});

  @override
  ConsumerState<ReportLocationScreen> createState() =>
      _ReportLocationScreenState();
}

class _ReportLocationScreenState extends ConsumerState<ReportLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(reportDraftProvider);
    _addressController = TextEditingController(text: draft.address);
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(reportDraftProvider);
    final isLost = draft.reportType == ReportType.lost;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportLocationTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/report/new/photos'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(PetSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepIndicator(current: 4, total: 6),
              const SizedBox(height: PetSpacing.xl),
              Text(
                l10n.reportLocationTitle,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: PetSpacing.xs),
              Text(
                isLost
                    ? l10n.reportLocationLostQuestion
                    : l10n.reportLocationFoundQuestion,
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
                        _buildMapPlaceholder(context),
                        const SizedBox(height: PetSpacing.xl),
                        PetInput(
                          label: isLost
                              ? l10n.reportLocationLostLabel
                              : l10n.reportLocationFoundLabel,
                          hint: l10n.reportLocationHint,
                          controller: _addressController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.requiredLocation;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: PetSpacing.md),
                        Text(
                          l10n.reportLocationExample,
                          style: Theme.of(context).textTheme.bodySmall,
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

  Widget _buildMapPlaceholder(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      height: 200,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: PetRadius.lgAll,
        border: Border.all(color: PetColors.border),
      ),
      child: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(1.2136, -77.2811),
              initialZoom: 13,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.petlink.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: const LatLng(1.2136, -77.2811),
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.location_on,
                      size: 42,
                      color: PetColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: PetSpacing.sm,
            right: PetSpacing.sm,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withValues(
                  alpha: 0.9,
                ),
                borderRadius: PetRadius.smAll,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PetSpacing.sm,
                  vertical: PetSpacing.xs,
                ),
                child: Text(
                  l10n.reportLocationMapTitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: PetSpacing.xs,
            right: PetSpacing.sm,
            child: Text(
              '\u00A9 OpenStreetMap contributors',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                backgroundColor: Theme.of(context).colorScheme.surface.withValues(
                  alpha: 0.85,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: PetSpacing.md,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PetSpacing.md,
                  vertical: PetSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: PetColors.primary,
                  borderRadius: PetRadius.xxlAll,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.my_location, size: 16, color: PetColors.surface),
                    const SizedBox(width: PetSpacing.xs),
                    Text(
                      l10n.useCurrentLocation,
                      style: TextStyle(
                        color: PetColors.surface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.go('/report/new/photos'),
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
                _saveLocation(ref);
                context.go('/report/new/details');
              }
            },
            icon: Icons.arrow_forward,
          ),
        ),
      ],
    );
  }

  void _saveLocation(WidgetRef ref) {
    final notifier = ref.read(reportDraftProvider.notifier);
    notifier.setLocation(
      latitude: 1.2136, // Mock coordinates for Pasto
      longitude: -77.2811,
      address: _addressController.text.trim(),
    );
  }
}
