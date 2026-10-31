import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petlink/l10n/app_localizations.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/theme/pet_tokens.dart';
import '../../../shared/widgets/photo_preview.dart';
import '../providers/report_draft_provider.dart';
import 'widgets/report_flow_stepper.dart';

class ReportPhotosScreen extends ConsumerStatefulWidget {
  const ReportPhotosScreen({super.key});

  @override
  ConsumerState<ReportPhotosScreen> createState() => _ReportPhotosScreenState();
}

class _ReportPhotosScreenState extends ConsumerState<ReportPhotosScreen> {
  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (picked != null) {
      ref.read(reportDraftProvider.notifier).addPhoto(picked.path);
    }
  }

  void _showSourcePicker() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: PetTokens.surfaceOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.reportPhotosAddPrompt,
                  style: PetTokens.displayThemed(context, 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: PetTokens.mintBgOf(context),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      PhosphorIconsBold.camera,
                      color: PetTokens.mint,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    l10n.takePhoto,
                    style: PetTokens.bodyThemed(context, 15, color: PetTokens.inkOf(context), weight: FontWeight.w700),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickPhoto(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: PetTokens.isDark(context)
                          ? const Color(0xFF382338)
                          : const Color(0xFFEFE3EC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      PhosphorIconsBold.image,
                      color: PetTokens.plumAccentOf(context),
                      size: 22,
                    ),
                  ),
                  title: Text(
                    l10n.gallery,
                    style: PetTokens.bodyThemed(context, 15, color: PetTokens.inkOf(context), weight: FontWeight.w700),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickPhoto(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(reportDraftProvider);
    final photoCount = draft.photos.length;
    final isFull = photoCount >= 3;

    return Scaffold(
      backgroundColor: PetTokens.bgOf(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Stepper oficial Paso 3 de 6
            ReportFlowStepper(
              currentStep: 3,
              stepTitle: l10n.reportPhotosTitle,
              onBack: () => context.pop(),
            ),

            // Contenido
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  PetTokens.gutter,
                  12,
                  PetTokens.gutter,
                  110,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Título según Paso3Fotos.dc.html
                    Text(
                      l10n.reportPhotosHeading,
                      style: PetTokens.displayThemed(context, 34),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.reportPhotosDescription,
                      style: PetTokens.bodyThemed(context, 15, color: PetTokens.mutedOf(context)),
                    ),
                    const SizedBox(height: 20),

                    // Escenario Polaroid interactivo (Paso3Fotos.dc.html)
                    _PolaroidStage(
                      photos: draft.photos,
                      onDeletePhoto: (index) {
                        ref.read(reportDraftProvider.notifier).removePhoto(index);
                      },
                      onTapAdd: isFull ? null : _showSourcePicker,
                    ),
                    const SizedBox(height: 20),

                    // Indicador de 3 puntos (dots)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < 3; i++) ...[
                          AnimatedContainer(
                            duration: PetTokens.dFast,
                            width: i < photoCount ? 24 : 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: i < photoCount
                                  ? (PetTokens.isDark(context)
                                      ? PetTokens.lostTextOf(context)
                                      : PetTokens.clay)
                                  : (PetTokens.isDark(context)
                                      ? PetTokens.trackOf(context)
                                      : const Color(0xFFE3D6CB)),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          if (i < 2) const SizedBox(width: 8),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Botón para agregar foto
                    InkWell(
                      onTap: isFull ? null : _showSourcePicker,
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: isFull
                              ? (PetTokens.isDark(context)
                                  ? const Color(0xFF1E1924)
                                  : const Color(0xFFE8E0D8))
                              : (PetTokens.isDark(context)
                                  ? const Color(0xFF382338)
                                  : const Color(0xFFEFE3EC)),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              PhosphorIconsBold.cameraPlus,
                              color: isFull
                                  ? PetTokens.mutedOf(context)
                                  : PetTokens.plumAccentOf(context),
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isFull
                                  ? l10n.reportPhotosFull
                                  : (photoCount == 0
                                      ? l10n.reportPhotosAddPrompt
                                      : l10n.addAnotherPhoto(photoCount)),
                              style: PetTokens.body(
                                15,
                                color: isFull
                                    ? PetTokens.mutedOf(context)
                                    : PetTokens.plumAccentOf(context),
                                weight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Botones inferiores (Volver + Continuar)
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
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 110,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: PetTokens.plum, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Volver',
                        style: PetTokens.body(
                          15,
                          color: PetTokens.plum,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => context.push('/report/new/location'),
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
// ESCENARIO POLAROID (Paso3Fotos.dc.html)
// -----------------------------------------------------------------------------
class _PolaroidStage extends StatelessWidget {
  const _PolaroidStage({
    required this.photos,
    required this.onDeletePhoto,
    required this.onTapAdd,
  });

  final List<String> photos;
  final ValueChanged<int> onDeletePhoto;
  final VoidCallback? onTapAdd;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return InkWell(
        onTap: onTapAdd,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 310,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: PetTokens.isDark(context)
                  ? PetTokens.borderOf(context)
                  : const Color(0xFFD6C6BA),
              width: 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: PetTokens.isDark(context)
                      ? const Color(0xFF382338)
                      : const Color(0xFFEFE3EC),
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.center,
                child: Icon(
                  PhosphorIconsBold.camera,
                  color: PetTokens.plumAccentOf(context),
                  size: 38,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                AppLocalizations.of(context)!.reportPhotosEmpty,
                style: PetTokens.displayThemed(context, 18),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.reportPhotosEmptyHint,
                style: PetTokens.body(13, color: PetTokens.mutedOf(context)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final captions = ['de frente', 'de perfil', 'cuerpo entero'];
    final rotations = [-0.10, 0.08, -0.04];

    return SizedBox(
      height: 310,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (int i = 0; i < photos.length; i++) ...[
            Transform.rotate(
              angle: rotations[i % rotations.length],
              child: _PolaroidFrame(
                photoPath: photos[i],
                caption: captions[i % captions.length],
                onDelete: () => onDeletePhoto(i),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PolaroidFrame extends StatelessWidget {
  const _PolaroidFrame({
    required this.photoPath,
    required this.caption,
    required this.onDelete,
  });

  final String photoPath;
  final String caption;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 196,
      height: 236,
      decoration: BoxDecoration(
        color: PetTokens.isDark(context)
            ? const Color(0xFF261F2C)
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: PetTokens.isDark(context)
              ? PetTokens.borderOf(context)
              : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: PetTokens.isDark(context)
                ? Colors.black.withValues(alpha: 0.4)
                : const Color(0x2E2A1A29),
            offset: const Offset(0, 14),
            blurRadius: 30,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
      child: Column(
        children: [
          // Imagen de la foto
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: photoPath.startsWith('http')
                      ? Image.network(photoPath, fit: BoxFit.cover)
                      : buildLocalPhotoPreview(
                          photoPath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, _, _) => const Center(
                            child: Icon(Icons.broken_image, color: PetTokens.muted),
                          ),
                        ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: InkWell(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Leyenda manuscrita estilo Polaroid
          Text(
            caption,
            style: PetTokens.display(
              15,
              color: PetTokens.plumAccentOf(context),
              italic: true,
            ),
          ),
        ],
      ),
    );
  }
}
