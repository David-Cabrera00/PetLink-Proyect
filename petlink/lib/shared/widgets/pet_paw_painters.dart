import 'package:flutter/material.dart';

import '../../core/theme/pet_tokens.dart';

/// Huella de mascota (viewBox 24x24 del diseño).
class PawPainter extends CustomPainter {
  const PawPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true;
    canvas
      ..save()
      ..scale(s);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(12, 16), width: 9, height: 7.6),
      paint,
    );
    for (final c in const [
      Offset(6.5, 10.5),
      Offset(10, 7),
      Offset(14, 7),
      Offset(17.5, 10.5),
    ]) {
      canvas.drawCircle(c, 2, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PawPainter oldDelegate) => oldDelegate.color != color;
}

/// Widget de huella con tamaño y color.
class PetPaw extends StatelessWidget {
  const PetPaw({super.key, this.size = 24, this.color = PetTokens.clay});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(size),
        painter: PawPainter(color: color),
      ),
    );
  }
}

/// Pin en forma de gota (viewBox 44x58) con casa blanca opcional.
class PinPainter extends CustomPainter {
  const PinPainter({
    this.color = PetTokens.clay,
    this.houseColor = PetTokens.cream,
    this.showHouse = true,
  });

  final Color color;
  final Color houseColor;
  final bool showHouse;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 44;
    canvas
      ..save()
      ..scale(s);
    final drop = Path()
      ..moveTo(22, 58)
      ..cubicTo(22, 58, 0, 36, 0, 22)
      ..arcToPoint(const Offset(44, 22), radius: const Radius.circular(22))
      ..cubicTo(44, 36, 22, 58, 22, 58)
      ..close();
    canvas.drawPath(drop, Paint()..color = color);
    if (showHouse) {
      final house = Path()
        ..moveTo(14, 26)
        ..lineTo(22, 19)
        ..lineTo(30, 26)
        ..lineTo(30, 34)
        ..lineTo(14, 34)
        ..close();
      canvas.drawPath(house, Paint()..color = houseColor);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PinPainter old) =>
      old.color != color ||
      old.houseColor != houseColor ||
      old.showHouse != showHouse;
}

class PetPin extends StatelessWidget {
  const PetPin({super.key, this.width = 44, this.color = PetTokens.clay});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(width, width * 58 / 44),
        painter: PinPainter(color: color),
      ),
    );
  }
}

/// Pin oficial del mapa según `ExplorarMapa.dc.html` (52x58 px con reborde blanco y huella).
class PetMapPinPainter extends CustomPainter {
  const PetMapPinPainter({
    required this.color,
    this.strokeColor = Colors.white,
    this.pawColor = Colors.white,
  });

  final Color color;
  final Color strokeColor;
  final Color pawColor;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 52;
    canvas
      ..save()
      ..scale(s);

    final drop = Path()
      ..moveTo(26, 56)
      ..cubicTo(26, 56, 4, 36, 4, 22)
      ..arcToPoint(const Offset(48, 22), radius: const Radius.circular(22))
      ..cubicTo(48, 36, 26, 56, 26, 56)
      ..close();

    canvas.drawPath(drop, Paint()..color = color);
    canvas.drawPath(
      drop,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    canvas
      ..save()
      ..translate(14, 9);
    PawPainter(color: pawColor).paint(canvas, const Size.square(24));
    canvas
      ..restore()
      ..restore();
  }

  @override
  bool shouldRepaint(PetMapPinPainter old) =>
      old.color != color ||
      old.strokeColor != strokeColor ||
      old.pawColor != pawColor;
}

class PetMapPin extends StatelessWidget {
  const PetMapPin({
    super.key,
    required this.color,
    this.width = 48,
    this.isSelected = false,
  });

  final Color color;
  final double width;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? 1.25 : 1.0,
      duration: const Duration(milliseconds: 260),
      curve: PetTokens.bounce,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(width, width * 58 / 52),
          painter: PetMapPinPainter(color: color),
        ),
      ),
    );
  }
}

/// Icono de marca: cuadro redondeado crema con pin ciruela y huella clay
/// (viewBox 76x76 del diseño).
class PetLogoMarkPainter extends CustomPainter {
  const PetLogoMarkPainter({
    this.background = PetTokens.cream,
    this.pin = PetTokens.plum,
    this.paw = PetTokens.clay,
  });

  final Color background;
  final Color pin;
  final Color paw;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 76;
    canvas
      ..save()
      ..scale(s);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 76, 76),
        const Radius.circular(22),
      ),
      Paint()..color = background,
    );
    final drop = Path()
      ..moveTo(38, 62)
      ..cubicTo(38, 62, 20, 45, 20, 32)
      ..arcToPoint(const Offset(56, 32), radius: const Radius.circular(18))
      ..cubicTo(56, 45, 38, 62, 38, 62)
      ..close();
    canvas.drawPath(drop, Paint()..color = pin);
    canvas
      ..save()
      ..translate(26, 18);
    PawPainter(color: paw).paint(canvas, const Size.square(24));
    canvas
      ..restore()
      ..restore();
  }

  @override
  bool shouldRepaint(PetLogoMarkPainter old) =>
      old.background != background || old.pin != pin || old.paw != paw;
}

class PetLogoMark extends StatelessWidget {
  const PetLogoMark({
    super.key,
    this.size = 40,
    this.background = PetTokens.cream,
    this.pin = PetTokens.plum,
  });

  final double size;
  final Color background;
  final Color pin;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(size),
        painter: PetLogoMarkPainter(background: background, pin: pin),
      ),
    );
  }
}

/// Wordmark "PetLink": "Pet" en Fraunces itálica + "Link" en Manrope 800.
class PetWordmark extends StatelessWidget {
  const PetWordmark({
    super.key,
    this.size = 44,
    this.petColor = PetTokens.clayText,
    this.linkColor = PetTokens.plum,
  });

  final double size;
  final Color petColor;
  final Color linkColor;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Pet',
            style: PetTokens.display(size, color: petColor, italic: true),
          ),
          TextSpan(
            text: 'Link',
            style: PetTokens.body(
              size,
              color: linkColor,
              weight: FontWeight.w800,
              height: 1.05,
            ).copyWith(letterSpacing: -size * 0.02),
          ),
        ],
      ),
    );
  }
}

