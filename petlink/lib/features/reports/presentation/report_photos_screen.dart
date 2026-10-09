import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/theme/pet_colors.dart';
import '../../../core/theme/pet_spacing.dart';
import '../../../core/theme/pet_radius.dart';
import '../../../design_system/buttons/pet_button.dart';
import '../../../shared/widgets/step_indicator.dart';
import '../providers/report_draft_provider.dart';

class ReportPhotosScreen extends ConsumerStatefulWidget {
  const ReportPhotosScreen({super.key});

  @override
  ConsumerState<ReportPhotosScreen> createState() => _ReportPhotosScreenState();
}

class _ReportPhotosScreenState extends ConsumerState<ReportPhotosScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(reportDraftProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportPhotosTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/report/new/pet-info'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(PetSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepIndicator(current: 3, total: 6),
              const SizedBox(height: PetSpacing.xl),
              Text(
                l10n.reportPhotosHeading,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: PetSpacing.xs),
              Text(
                l10n.reportPhotosDescription,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: PetSpacing.xl),
              Expanded(
                child: Column(
                  children: [
                    if (draft.photos.isEmpty)
                      _buildEmptyPhotosPlaceholder(context)
                    else
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: PetSpacing.md,
                                mainAxisSpacing: PetSpacing.md,
                                childAspectRatio: 1,
                              ),
                          itemCount:
                              draft.photos.length +
                              (draft.photos.length < 3 ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == draft.photos.length) {
                              return _buildAddPhotoCard(context, ref);
                            }
                            return _buildPhotoCard(context, ref, index);
                          },
                        ),
                      ),
                    const SizedBox(height: PetSpacing.lg),
                    if (draft.photos.isNotEmpty)
                      Text(
                        l10n.reportPhotosCount(count: draft.photos.length),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
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

  Widget _buildEmptyPhotosPlaceholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: PetColors.primarySoft,
              borderRadius: PetRadius.xlAll,
            ),
            child: Icon(
              Icons.camera_alt_outlined,
              size: 48,
              color: PetColors.primary,
            ),
          ),
          const SizedBox(height: PetSpacing.lg),
          Text(
            l10n.reportPhotosAddPrompt,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: PetSpacing.xs),
          Text(
            l10n.reportPhotosLimit,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: PetSpacing.xl),
          PetButton(
            label: l10n.addPhoto,
            onPressed: () => _showPhotoOptions(context, ref),
            icon: Icons.add_a_photo,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(BuildContext context, WidgetRef ref, int index) {
    final photo = ref.read(reportDraftProvider).photos[index];
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: PetRadius.lgAll,
            border: Border.all(color: PetColors.border),
          ),
          child: ClipRRect(
            borderRadius: PetRadius.lgAll,
            child: photo.startsWith('http')
                ? Image.network(
                    photo,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),
        ),
        Positioned(
          top: PetSpacing.xs,
          right: PetSpacing.xs,
          child: GestureDetector(
            onTap: () =>
                ref.read(reportDraftProvider.notifier).removePhoto(index),
            child: Container(
              padding: const EdgeInsets.all(PetSpacing.xs),
              decoration: BoxDecoration(
                color: PetColors.lost,
                borderRadius: PetRadius.smAll,
              ),
              child: Icon(Icons.close, size: 16, color: PetColors.surface),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: PetColors.background,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 32,
          color: PetColors.textSecondary.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildAddPhotoCard(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showPhotoOptions(context, ref),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: PetRadius.lgAll,
          border: Border.all(
            color: PetColors.primary,
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(PetSpacing.md),
              decoration: BoxDecoration(
                color: PetColors.primarySoft,
                borderRadius: PetRadius.lgAll,
              ),
              child: Icon(
                Icons.add_a_photo,
                size: 32,
                color: PetColors.primary,
              ),
            ),
            const SizedBox(height: PetSpacing.sm),
            Text(
              AppLocalizations.of(context)!.addPhoto,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: PetColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(PetSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.addPhoto,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: PetSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _buildPhotoOption(
                        context,
                        Icons.camera_alt,
                        l10n.takePhoto,
                        () {
                          Navigator.pop(context);
                          _simulatePhoto(ref);
                        },
                      ),
                    ),
                    const SizedBox(width: PetSpacing.md),
                    Expanded(
                      child: _buildPhotoOption(
                        context,
                        Icons.photo_library,
                        l10n.gallery,
                        () {
                          Navigator.pop(context);
                          _simulatePhoto(ref);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PetSpacing.lg),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoOption(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(PetSpacing.lg),
        decoration: BoxDecoration(
          color: PetColors.surface,
          borderRadius: PetRadius.lgAll,
          border: Border.all(color: PetColors.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(PetSpacing.md),
              decoration: BoxDecoration(
                color: PetColors.primarySoft,
                borderRadius: PetRadius.lgAll,
              ),
              child: Icon(icon, size: 28, color: PetColors.primary),
            ),
            const SizedBox(height: PetSpacing.sm),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  void _simulatePhoto(WidgetRef ref) {
    final mockPhotos = [
      'https://images.unsplash.com/photo-1552053831-71594a27632d?w=400',
      'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=400',
      'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=400',
    ];
    final currentCount = ref.read(reportDraftProvider).photos.length;
    if (currentCount < 3) {
      ref.read(reportDraftProvider.notifier).addPhoto(mockPhotos[currentCount]);
    }
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(reportDraftProvider);
    final canContinue = draft.photos.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.go('/report/new/pet-info'),
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
            onPressed: canContinue
                ? () => context.go('/report/new/location')
                : null,
            icon: Icons.arrow_forward,
          ),
        ),
      ],
    );
  }
}
