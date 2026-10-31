import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petlink/l10n/app_localizations.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../core/theme/pet_tokens.dart';
import '../../shared/widgets/pet_paw_painters.dart';
import '../auth/providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_mode_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: PetTokens.bgOf(context),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: PetTokens.contentBottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Hero Ciruela con patrón de anillos y Avatar orbital
            _ProfileHero(
              user: user,
              onPickAvatar: () => _pickAvatar(context, ref),
            ),

            // 2. Tarjetas y opciones con solapamiento superior (-36px)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PetTokens.gutter),
              child: Transform.translate(
                offset: const Offset(0, -32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tarjeta de acciones: Mis reportes y Editar nombre
                    _buildAccountCard(context, ref, user, l10n),
                    const SizedBox(height: 24),

                    // Selector de tema (Apariencia) segun Perfil.dc.html
                    _buildThemeSection(context, ref, themeMode, l10n),
                    const SizedBox(height: 22),

                    // Selector de idioma (Español / English)
                    _buildLanguageSection(context, ref, locale, l10n),
                    const SizedBox(height: 26),

                    // Botón estilizado de Cerrar sesión
                    if (user != null)
                      _buildLogoutButton(context, ref, l10n),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TARJETA DE ACCIONES DE CUENTA
  // ---------------------------------------------------------------------------
  Widget _buildAccountCard(
    BuildContext context,
    WidgetRef ref,
    AuthUser? user,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: PetTokens.surfaceOf(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: PetTokens.borderOf(context)),
        boxShadow: PetTokens.shadowCardThemed(context),
      ),
      child: Column(
        children: [
          // Fila 1: Mis reportes
          InkWell(
            onTap: () => context.push('/reports/mine'),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: PetTokens.lostBgOf(context),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: PetPaw(size: 22, color: PetTokens.lostTextOf(context)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.reportsTitle,
                          style: PetTokens.body(
                            16,
                            color: PetTokens.inkOf(context),
                            weight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.profileDescription,
                          style: PetTokens.body(13, color: PetTokens.mutedOf(context)),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: PetTokens.mutedOf(context),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          // Divisor suave
          Container(
            height: 1,
            color: PetTokens.borderOf(context),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),

          // Fila 2: Editar nombre
          InkWell(
            onTap: user != null
                ? () => _editName(context, ref, user.name)
                : null,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
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
                      PhosphorIconsBold.pencilSimple,
                      size: 20,
                      color: PetTokens.plumAccentOf(context),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.authName,
                          style: PetTokens.body(
                            16,
                            color: PetTokens.inkOf(context),
                            weight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.authNameHint,
                          style: PetTokens.body(13, color: PetTokens.mutedOf(context)),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: PetTokens.mutedOf(context),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // APARIENCIA (TEMA SEGMENTADO SEGÚN Perfil.dc.html)
  // ---------------------------------------------------------------------------
  Widget _buildThemeSection(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentTheme,
    AppLocalizations l10n,
  ) {
    final themes = [
      (ThemeMode.system, l10n.themeSystem, PhosphorIconsBold.deviceMobile),
      (ThemeMode.light, l10n.themeLight, PhosphorIconsBold.sun),
      (ThemeMode.dark, l10n.themeDark, PhosphorIconsBold.moon),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text.rich(
            TextSpan(
              style: PetTokens.displayThemed(context, 22),
              children: [
                TextSpan(
                  text: l10n.appearance,
                  style: PetTokens.display(
                    22,
                    color: PetTokens.lostTextOf(context),
                    italic: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: PetTokens.cardSubtleOf(context),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              for (final (mode, label, icon) in themes) ...[
                Expanded(
                  child: InkWell(
                    onTap: () {
                      ref.read(themeModeProvider.notifier).setThemeMode(mode);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: PetTokens.dFast,
                      height: 68,
                      decoration: BoxDecoration(
                        color: currentTheme == mode
                            ? PetTokens.surfaceOf(context)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: currentTheme == mode
                            ? [
                                BoxShadow(
                                  color: PetTokens.isDark(context)
                                      ? Colors.black.withValues(alpha: 0.25)
                                      : const Color(0x1A2A1A29),
                                  offset: const Offset(0, 4),
                                  blurRadius: 14,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            size: 22,
                            color: currentTheme == mode
                                ? PetTokens.plumAccentOf(context)
                                : PetTokens.mutedOf(context),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            label,
                            style: PetTokens.body(
                              13,
                              color: currentTheme == mode
                                  ? PetTokens.plumAccentOf(context)
                                  : PetTokens.mutedOf(context),
                              weight: currentTheme == mode
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // IDIOMA (SEGMENTADO)
  // ---------------------------------------------------------------------------
  Widget _buildLanguageSection(
    BuildContext context,
    WidgetRef ref,
    Locale currentLocale,
    AppLocalizations l10n,
  ) {
    final isSpanish = currentLocale.languageCode == 'es';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text.rich(
            TextSpan(
              style: PetTokens.displayThemed(context, 22),
              children: [
                TextSpan(
                  text: l10n.language,
                  style: PetTokens.display(
                    22,
                    color: PetTokens.lostTextOf(context),
                    italic: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: PetTokens.cardSubtleOf(context),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale(const Locale('es'));
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: PetTokens.dFast,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSpanish ? PetTokens.surfaceOf(context) : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isSpanish ? PetTokens.shadowNav : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      l10n.languageSpanish,
                      style: PetTokens.body(
                        14,
                        color: isSpanish ? PetTokens.plumAccentOf(context) : PetTokens.mutedOf(context),
                        weight: isSpanish ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: PetTokens.dFast,
                    height: 52,
                    decoration: BoxDecoration(
                      color: !isSpanish ? PetTokens.surfaceOf(context) : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: !isSpanish ? PetTokens.shadowNav : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      l10n.languageEnglish,
                      style: PetTokens.body(
                        14,
                        color: !isSpanish ? PetTokens.plumAccentOf(context) : PetTokens.mutedOf(context),
                        weight: !isSpanish ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // BOTÓN CERRAR SESIÓN
  // ---------------------------------------------------------------------------
  Widget _buildLogoutButton(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    return InkWell(
      onTap: () => ref.read(authProvider.notifier).logout(),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: PetTokens.isDark(context) ? PetTokens.lostBgOf(context) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: PetTokens.isDark(context)
                ? PetTokens.lostBorderOf(context)
                : const Color(0xFFE3D6CB),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsBold.signOut,
              color: PetTokens.lostTextOf(context),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.profileLogout,
              style: PetTokens.body(
                15,
                color: PetTokens.lostTextOf(context),
                weight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // OPERACIONES DE PERFIL
  // ---------------------------------------------------------------------------
  Future<void> _pickAvatar(BuildContext context, WidgetRef ref) async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (image == null) return;
    try {
      await ref.read(authProvider.notifier).uploadAvatar(image.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil actualizada')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo actualizar la foto: $error')),
        );
      }
    }
  }

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) async {
    final controller = TextEditingController(text: currentName);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: PetTokens.surfaceOf(dialogContext),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'Cambiar nombre',
          style: PetTokens.displayThemed(dialogContext, 20),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          maxLength: 60,
          style: PetTokens.body(15, color: PetTokens.inkOf(dialogContext)),
          decoration: InputDecoration(
            hintText: 'Tu nombre o apodo',
            hintStyle: PetTokens.body(15, color: PetTokens.placeholder),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: PetTokens.borderOf(dialogContext)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: PetTokens.plumAccentOf(dialogContext),
                width: 2,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancelar',
              style: PetTokens.body(
                14,
                color: PetTokens.mutedOf(dialogContext),
                weight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: PetTokens.plum,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: Text(
              'Guardar',
              style: PetTokens.body(14, color: PetTokens.cream, weight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (name == null || name.length < 2 || !context.mounted) return;
    try {
      await ref.read(authProvider.notifier).updateName(name);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nombre actualizado')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo actualizar el nombre: $error')),
        );
      }
    }
  }
}

// -----------------------------------------------------------------------------
// HERO SUPERIOR CURVO CON ANILLOS Y AVATAR ORBITAL (Perfil.dc.html)
// -----------------------------------------------------------------------------
class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.user, required this.onPickAvatar});

  final AuthUser? user;
  final VoidCallback onPickAvatar;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      decoration: BoxDecoration(
        color: PetTokens.isDark(context)
            ? const Color(0xFF2E1C2E)
            : PetTokens.plum,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Stack(
        children: [
          // Patrón de anillos concéntricos decorativos superiores
          Positioned(
            right: -20,
            top: top - 20,
            child: CustomPaint(
              size: const Size(200, 200),
              painter: _ConcentricRingsPainter(),
            ),
          ),

          // Contenido: Avatar + Datos del usuario
          Padding(
            padding: EdgeInsets.fromLTRB(
              PetTokens.gutter,
              top + 20,
              PetTokens.gutter,
              54,
            ),
            child: Row(
              children: [
                // Avatar orbital animado
                _OrbitalAvatar(
                  avatarUrl: user?.avatarUrl,
                  name: user?.name ?? 'PetLink',
                  onPickPhoto: onPickAvatar,
                ),
                const SizedBox(width: 18),

                // Textos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MIEMBRO DE LA MANADA',
                        style: PetTokens.body(
                          11,
                          color: const Color(0xFFF3B79F),
                          weight: FontWeight.w800,
                          letterSpacing: 0.14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildUserName(user?.name ?? 'Amigo PetLink'),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: PetTokens.body(
                          14,
                          color: const Color(0xFFD9C8D3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      final first = parts.first;
      final rest = parts.sublist(1).join(' ');
      return Text.rich(
        TextSpan(
          style: PetTokens.display(26, color: PetTokens.cream),
          children: [
            TextSpan(text: '$first '),
            TextSpan(
              text: rest,
              style: PetTokens.display(
                26,
                color: const Color(0xFFF29A7E),
                italic: true,
              ),
            ),
          ],
        ),
      );
    }

    return Text(
      fullName,
      style: PetTokens.display(26, color: PetTokens.cream),
    );
  }
}

// -----------------------------------------------------------------------------
// AVATAR CON ANILLO ORBITAL ANIMADO (14s)
// -----------------------------------------------------------------------------
class _OrbitalAvatar extends StatefulWidget {
  const _OrbitalAvatar({
    required this.avatarUrl,
    required this.name,
    required this.onPickPhoto,
  });

  final String? avatarUrl;
  final String name;
  final VoidCallback onPickPhoto;

  @override
  State<_OrbitalAvatar> createState() => _OrbitalAvatarState();
}

class _OrbitalAvatarState extends State<_OrbitalAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'PL';
    if (parts.length == 1) return parts[0].substring(0, math.min(2, parts[0].length)).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 114,
      height: 114,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Anillo orbital con huella girando (14s)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final angle = _controller.value * 2 * math.pi;
              return Transform.rotate(
                angle: angle,
                child: CustomPaint(
                  size: const Size(114, 114),
                  painter: _OrbitalRingPainter(),
                ),
              );
            },
          ),

          // Círculo del avatar interior (86x86)
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: PetTokens.isDark(context) ? const Color(0xFF2E2232) : PetTokens.cream,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x332A1A29),
                  offset: Offset(0, 6),
                  blurRadius: 16,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      widget.avatarUrl!,
                      width: 86,
                      height: 86,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildInitials(),
                    ),
                  )
                : _buildInitials(),
          ),

          // Botón de cámara flotante inferior derecho
          Positioned(
            right: 0,
            bottom: 0,
            child: InkWell(
              onTap: widget.onPickPhoto,
              customBorder: const CircleBorder(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: PetTokens.clay,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: PetTokens.isDark(context)
                        ? const Color(0xFF2E1C2E)
                        : PetTokens.plum,
                    width: 3,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26000000),
                      offset: Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  PhosphorIconsBold.camera,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitials() {
    return Text(
      _getInitials(widget.name),
      style: PetTokens.display(
        32,
        color: PetTokens.isDark(context) ? PetTokens.plumAccentOf(context) : PetTokens.plum,
        italic: true,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PINTOR DEL ANILLO ORBITAL
// -----------------------------------------------------------------------------
class _OrbitalRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Círculo punteado orbital
    final ringPaint = Paint()
      ..color = PetTokens.clay
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const dashCount = 20;
    const dashAngle = (2 * math.pi) / dashCount;
    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          i * dashAngle,
          dashAngle * 0.5,
          false,
          ringPaint,
        );
      }
    }

    // Huella orbital dibujada en la parte superior del anillo
    canvas.save();
    canvas.translate(center.dx - 8, 0);
    const PawPainter(color: PetTokens.clay).paint(canvas, const Size(16, 16));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------------------
// PINTOR DE ANILLOS CONCÉNTRICOS DECORATIVOS DEL HERO
// -----------------------------------------------------------------------------
class _ConcentricRingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.8, size.height * 0.2);
    final ringPaint = Paint()
      ..color = const Color(0xFF5E3E5E)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, 40, ringPaint);
    canvas.drawCircle(center, 70, ringPaint);
    canvas.drawCircle(center, 100, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
