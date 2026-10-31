import 'package:image_picker/image_picker.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../core/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/theme/pet_tokens.dart';
import '../../../shared/models/pet_report.dart';
import '../providers/report_draft_provider.dart';
import 'widgets/report_flow_stepper.dart';

class ReportPetInfoScreen extends ConsumerStatefulWidget {
  const ReportPetInfoScreen({super.key});

  @override
  ConsumerState<ReportPetInfoScreen> createState() =>
      _ReportPetInfoScreenState();
}

class _ReportPetInfoScreenState extends ConsumerState<ReportPetInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _breedController;
  late final TextEditingController _ageController;
  late final TextEditingController _colorController;

  String _species = 'Perro';
  String? _sex;
  String _size = 'Mediano';
  bool _isAnalyzingAi = false;
  String? _aiFeedback;

  Future<void> _pickAndAnalyzeWithAi(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (picked == null) return;

    ref.read(reportDraftProvider.notifier).addPhoto(picked.path);

    setState(() {
      _isAnalyzingAi = true;
      _aiFeedback = null;
    });

    try {
      final analysis = await ApiClient.instance.analyzePetImage(picked.path);
      ref.read(reportDraftProvider.notifier).applyAiAnalysis(analysis);

      if (mounted) {
        setState(() {
          final s = analysis['species']?.toString();
          if (s != null && s.isNotEmpty) _species = s;

          final b = analysis['breed']?.toString();
          if (b != null && b.isNotEmpty) _breedController.text = b;

          final c = analysis['color']?.toString();
          if (c != null && c.isNotEmpty) _colorController.text = c;

          final sz = analysis['size']?.toString();
          if (sz != null && sz.isNotEmpty) _size = sz;

          final sx = analysis['sex']?.toString();
          if (sx != null && sx.isNotEmpty) _sex = sx;

          _aiFeedback = '✨ ¡Datos completados por Gemini IA! Revisa y ajusta si es necesario.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiFeedback = '⚠️ No se pudo autocompletar (' + e.toString() + '). Puedes llenar los campos manualmente.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzingAi = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final draft = ref.read(reportDraftProvider);
    _nameController = TextEditingController(text: draft.name);
    _breedController = TextEditingController(text: draft.breed);
    _ageController = TextEditingController(text: draft.age);
    _colorController = TextEditingController(text: draft.color);

    if (draft.species.isNotEmpty) _species = draft.species;
    if (draft.sex.isNotEmpty) _sex = draft.sex;
    if (draft.size.isNotEmpty) _size = draft.size;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _saveDraft() {
    final notifier = ref.read(reportDraftProvider.notifier);
    notifier.setName(_nameController.text.trim());
    notifier.setSpecies(_species);
    notifier.setBreed(_breedController.text.trim());
    if (_sex != null) notifier.setSex(_sex!);
    notifier.setSize(_size);
    notifier.setAge(_ageController.text.trim());
    notifier.setColor(_colorController.text.trim());
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? true) {
      _saveDraft();
      context.push('/report/new/photos');
    }
  }

  Color _resolveTint(String colorText) {
    final key = colorText.trim().toLowerCase().split(' ').first;
    switch (key) {
      case 'dorado':
      case 'amarillo':
        return const Color(0xFFE3A857);
      case 'negro':
        return const Color(0xFF3A2E33);
      case 'blanco':
        return const Color(0xFFF4EEE6);
      case 'gris':
        return const Color(0xFFA9A1A6);
      case 'cafe':
      case 'caf\u00E9':
      case 'marron':
      case 'marr\u00F3n':
        return const Color(0xFF8A5A3B);
      case 'crema':
        return const Color(0xFFF0D9B5);
      case 'naranja':
        return const Color(0xFFE0894A);
      default:
        return PetTokens.dogTan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(reportDraftProvider);
    final isFound = draft.reportType == ReportType.found;
    final petName = _nameController.text.trim();
    final displayName = petName.isNotEmpty
        ? petName
        : (isFound ? l10n.foundPet : l10n.unnamedPet);

    final summaryParts = [
      _species,
      if (_sex != null) _sex,
      _size,
      if (_colorController.text.trim().isNotEmpty)
        _colorController.text.trim(),
    ];
    final summary = summaryParts.join(' \u00B7 ');

    return Scaffold(
      backgroundColor: PetTokens.bgOf(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Stepper oficial Paso 2 de 6
            ReportFlowStepper(
              currentStep: 2,
              stepTitle: l10n.reportPetInfoTitle,
              onBack: () {
                _saveDraft();
                context.pop();
              },
            ),

            // Contenido del formulario
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
                      // Tarjeta de previsualización reactiva (Paso2Datos.dc.html)
                      _PetIdCardPreview(
                        species: _species,
                        displayName: displayName,
                        summary: summary,
                        tintColor: _resolveTint(_colorController.text),
                      ),
                      const SizedBox(height: 14),
                      // Tarjeta para autocompletar con IA
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: PetTokens.isDark(context)
                              ? const Color(0xFF2E2230)
                              : const Color(0xFFFBF4ED),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: PetTokens.clay.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: PetTokens.clay.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.auto_awesome,
                                    color: PetTokens.clay,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Autocompletar con Foto (IA)',
                                    style: PetTokens.bodyThemed(
                                      context,
                                      14,
                                      color: PetTokens.inkOf(context),
                                      weight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sube una foto de la mascota y nuestra IA reconocerá automáticamente la especie, raza, color y tamaño.',
                              style: PetTokens.bodyThemed(
                                context,
                                12,
                                color: PetTokens.mutedOf(context),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_isAnalyzingAi)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(PetTokens.clay),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Analizando con Gemini IA...',
                                    style: PetTokens.bodyThemed(
                                      context,
                                      13,
                                      color: PetTokens.inkOf(context),
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _pickAndAnalyzeWithAi(ImageSource.camera),
                                      icon: const Icon(PhosphorIconsBold.camera, size: 16),
                                      label: const Text('Tomar foto'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: PetTokens.clay,
                                        side: const BorderSide(color: PetTokens.clay),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _pickAndAnalyzeWithAi(ImageSource.gallery),
                                      icon: const Icon(PhosphorIconsBold.image, size: 16),
                                      label: const Text('Galería'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: PetTokens.clay,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (_aiFeedback != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                _aiFeedback!,
                                style: PetTokens.bodyThemed(
                                  context,
                                  12,
                                  color: _aiFeedback!.startsWith('⚠️')
                                      ? Colors.redAccent
                                      : PetTokens.clay,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      if (draft.breed.isNotEmpty || draft.color.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: PetTokens.plum.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: PetTokens.plum.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: PetTokens.clay, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Datos precargados con IA a partir de tu foto. Puedes editarlos libremente.',
                                  style: PetTokens.bodyThemed(context, 13, color: PetTokens.inkOf(context), weight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Nombre
                      _buildFieldLabel(
                        isFound
                            ? l10n.reportPetInfoNameOptional
                            : l10n.reportPetInfoName,
                      ),
                      _buildTextInput(
                        controller: _nameController,
                        hintText: isFound ? 'Ej. Desconocido o Placa' : 'Ej. Luna',
                        onChanged: (_) => setState(() {}),
                        validator: isFound
                            ? null
                            : (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return l10n.requiredName;
                                }
                                return null;
                              },
                      ),
                      const SizedBox(height: 14),

                      // Especie y Sexo en fila
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel(l10n.reportPetInfoSpecies),
                                Row(
                                  children: [
                                    _buildSelectChip(
                                      label: 'Perro',
                                      isSelected: _species == 'Perro',
                                      onTap: () => setState(() => _species = 'Perro'),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildSelectChip(
                                      label: 'Gato',
                                      isSelected: _species == 'Gato',
                                      onTap: () => setState(() => _species = 'Gato'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel(l10n.reportPetInfoSex),
                                Row(
                                  children: [
                                    _buildSelectChip(
                                      label: 'Macho',
                                      icon: PhosphorIconsBold.genderMale,
                                      isSelected: _sex == 'Macho',
                                      onTap: () => setState(() => _sex = 'Macho'),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildSelectChip(
                                      label: 'Hembra',
                                      icon: PhosphorIconsBold.genderFemale,
                                      isSelected: _sex == 'Hembra',
                                      onTap: () => setState(() => _sex = 'Hembra'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Raza
                      _buildFieldLabel(l10n.reportPetInfoBreed),
                      _buildTextInput(
                        controller: _breedController,
                        hintText: 'Ej. Golden Retriever o Mestizo',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 14),

                      // Tamaño
                      _buildFieldLabel(l10n.reportPetInfoSize),
                      Row(
                        children: [
                          _buildSelectChip(
                            label: 'Peque\u00F1o',
                            isSelected: _size == 'Peque\u00F1o',
                            onTap: () => setState(() => _size = 'Peque\u00F1o'),
                          ),
                          const SizedBox(width: 8),
                          _buildSelectChip(
                            label: 'Mediano',
                            isSelected: _size == 'Mediano',
                            onTap: () => setState(() => _size = 'Mediano'),
                          ),
                          const SizedBox(width: 8),
                          _buildSelectChip(
                            label: 'Grande',
                            isSelected: _size == 'Grande',
                            onTap: () => setState(() => _size = 'Grande'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Edad y Color en 2 columnas
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('Edad aprox.'),
                                _buildTextInput(
                                  controller: _ageController,
                                  hintText: 'Ej. 3 a\u00F1os / Cachorro',
                                  onChanged: (_) => setState(() {}),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('Color'),
                                _buildTextInput(
                                  controller: _colorController,
                                  hintText: 'Ej. Dorado / Blanco',
                                  onChanged: (_) => setState(() {}),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                    onTap: () {
                      _saveDraft();
                      context.pop();
                    },
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

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 6),
      child: Text(
        label,
        style: PetTokens.bodyThemed(
          context,
          13,
          color: PetTokens.inkOf(context),
          weight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hintText,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      style: PetTokens.bodyThemed(context, 15, color: PetTokens.inkOf(context)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: PetTokens.body(15, color: PetTokens.placeholder),
        filled: true,
        fillColor: PetTokens.surfaceHigherOf(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: PetTokens.borderOf(context), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: PetTokens.plumAccentOf(context), width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: PetTokens.clay, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: PetTokens.clay, width: 2.0),
        ),
      ),
    );
  }

  Widget _buildSelectChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: PetTokens.dFast,
          height: 44,
          decoration: BoxDecoration(
            color: isSelected
                ? (PetTokens.isDark(context)
                    ? const Color(0xFF6B366B)
                    : PetTokens.plum)
                : PetTokens.surfaceHigherOf(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? (PetTokens.isDark(context)
                      ? const Color(0xFF9E5C9E)
                      : PetTokens.plum)
                  : PetTokens.borderOf(context),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 17,
                  color: isSelected
                      ? Colors.white
                      : (PetTokens.isDark(context)
                          ? PetTokens.clayLight
                          : PetTokens.clay),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: PetTokens.bodyThemed(
                  context,
                  13,
                  color: isSelected ? Colors.white : PetTokens.inkOf(context),
                  weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// FICHA DE PREVISUALIZACIÓN REACTIVA (Paso2Datos.dc.html)
// -----------------------------------------------------------------------------
class _PetIdCardPreview extends StatelessWidget {
  const _PetIdCardPreview({
    required this.species,
    required this.displayName,
    required this.summary,
    required this.tintColor,
  });

  final String species;
  final String displayName;
  final String summary;
  final Color tintColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PetTokens.isDark(context)
            ? const Color(0xFF2B1D2C)
            : PetTokens.plum,
        borderRadius: BorderRadius.circular(24),
        border: PetTokens.isDark(context)
            ? Border.all(color: const Color(0xFF5A3E5C), width: 1.5)
            : null,
        boxShadow: PetTokens.shadowCardThemed(context),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Silueta ilustrada reactiva
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: PetTokens.isDark(context)
                  ? const Color(0xFF1E131E)
                  : PetTokens.plumDeep,
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: CustomPaint(
              size: const Size(48, 48),
              painter: _PetSilhouettePainter(
                species: species,
                tintColor: tintColor,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Títulos y datos reactivos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FICHA DE B\u00DASQUEDA',
                  style: PetTokens.body(
                    10,
                    color: const Color(0xFFF3B79F),
                    weight: FontWeight.w800,
                    letterSpacing: 0.14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PetTokens.display(
                    24,
                    color: PetTokens.cream,
                    italic: true,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PetTokens.body(12, color: const Color(0xFFD9C8D3)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PetSilhouettePainter extends CustomPainter {
  const _PetSilhouettePainter({
    required this.species,
    required this.tintColor,
  });

  final String species;
  final Color tintColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final isCat = species.toLowerCase().contains('gato');

    final bodyPaint = Paint()..color = tintColor;
    final earPaint = Paint()..color = isCat ? tintColor : PetTokens.dogEar;

    if (isCat) {
      // Orejas triangulares
      final earPath = Path()
        ..moveTo(center.dx - 14, center.dy - 6)
        ..lineTo(center.dx - 12, center.dy - 20)
        ..lineTo(center.dx, center.dy - 10)
        ..close()
        ..moveTo(center.dx + 14, center.dy - 6)
        ..lineTo(center.dx + 12, center.dy - 20)
        ..lineTo(center.dx, center.dy - 10)
        ..close();
      canvas.drawPath(earPath, earPaint);
      canvas.drawCircle(center, 14, bodyPaint);
    } else {
      // Orejas caídas de perro
      final earPaintStroke = Paint()
        ..color = earPaint.color
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(center.dx - 12, center.dy - 8), Offset(center.dx - 15, center.dy + 8), earPaintStroke);
      canvas.drawLine(Offset(center.dx + 12, center.dy - 8), Offset(center.dx + 15, center.dy + 8), earPaintStroke);
      canvas.drawCircle(center, 13, bodyPaint);
    }

    // Ojos y nariz
    final featurePaint = Paint()..color = PetTokens.ink;
    canvas.drawCircle(Offset(center.dx - 4, center.dy - 2), 1.8, featurePaint);
    canvas.drawCircle(Offset(center.dx + 4, center.dy - 2), 1.8, featurePaint);
    canvas.drawCircle(Offset(center.dx, center.dy + 3), 2.2, featurePaint);
  }

  @override
  bool shouldRepaint(covariant _PetSilhouettePainter oldDelegate) =>
      oldDelegate.species != species || oldDelegate.tintColor != tintColor;
}
