import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Raggi sk-ui (design.md): base 8px.
class SkRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 18;
  static const double xl = 22;
  static const double pill = 999;
}

/// Token sk-ui portati 1:1 da `packages/ui/src/foundation/tokens.css`.
/// Tema chiaro ("plastica") e tema scuro ("grafite").
class SkTokens {
  const SkTokens({
    required this.brightness,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.bgTop,
    required this.bgMid,
    required this.bgBottom,
    required this.raisedHi,
    required this.raisedMid,
    required this.raisedLo,
    required this.wellTop,
    required this.wellMid,
    required this.wellLo,
    required this.wellEdge,
    required this.edge,
    required this.shadow,
    required this.shadowSoft,
    required this.highlight,
    required this.accent,
    required this.accentHi,
    required this.accentLo,
    required this.accentInk,
    required this.success,
    required this.danger,
    required this.warn,
    required this.warnHi,
    required this.warnInk,
    required this.desk,
    required this.navMid,
    required this.alertHi,
    required this.alertMid,
    required this.alertLo,
  });

  final Brightness brightness;

  // Inchiostro (mai #000).
  final Color ink;
  final Color ink2;
  final Color ink3;

  // Superficie plastica di base.
  final Color bgTop;
  final Color bgMid;
  final Color bgBottom;

  // Superfici "raised" (pulsanti, pastiglie, teste tabella).
  final Color raisedHi;
  final Color raisedMid;
  final Color raisedLo;

  // Pozzo/incavo (well): input, vassoi, track.
  final Color wellTop;
  final Color wellMid;
  final Color wellLo;
  final Color wellEdge;

  // Bordi, ombre, lucido.
  final Color edge;
  final Color shadow;
  final Color shadowSoft;
  final Color highlight;

  // Accent — hsl(220, 80%, 51%).
  final Color accent;
  final Color accentHi;
  final Color accentLo;
  final Color accentInk;

  // Semantiche (saturation <= 80%).
  final Color success;
  final Color danger;
  final Color warn;
  final Color warnHi;
  final Color warnInk;

  // Scrivania e superfici statiche.
  final Color desk;
  final Color navMid;
  final Color alertHi;
  final Color alertMid;
  final Color alertLo;

  static const light = SkTokens(
    brightness: Brightness.light,
    ink: Color(0xFF1A1A1A),
    ink2: Color(0xFF4A4A4A),
    ink3: Color(0xFF6A7383),
    bgTop: Color(0xFFF8FAFC),
    bgMid: Color(0xFFE9EEF5),
    bgBottom: Color(0xFFCFD7E4),
    raisedHi: Color(0xFFFDFEFE),
    raisedMid: Color(0xFFEEF2F7),
    raisedLo: Color(0xFFDDE4EE),
    wellTop: Color(0xFFC4CDD9),
    wellMid: Color(0xFFDBE2EA),
    wellLo: Color(0xFFE7ECF2),
    wellEdge: Color(0x61485470),
    edge: Color(0x574F5D7A),
    shadow: Color(0x2E1F2937),
    shadowSoft: Color(0x1F1F2937),
    highlight: Color(0xB8FFFFFF),
    accent: Color(0xFF2264E2),
    accentHi: Color(0xFF5B8DFF),
    accentLo: Color(0xFF1C4FB8),
    accentInk: Color(0xFF0F3EA6),
    success: Color(0xFF23875A),
    danger: Color(0xFFC84343),
    warn: Color(0xFFC07C1D),
    warnHi: Color(0xFFE6A94F),
    warnInk: Color(0xFF7A4E0F),
    desk: Color(0xFFE2E7EE),
    navMid: Color(0xFFE9EEF5),
    alertHi: Color(0xFFF4F7FC),
    alertMid: Color(0xFFE7EDF6),
    alertLo: Color(0xFFDBE3F0),
  );

  static const dark = SkTokens(
    brightness: Brightness.dark,
    ink: Color(0xFFEEF2F8),
    ink2: Color(0xFFC7D0E0),
    ink3: Color(0xFF9CA8BC),
    bgTop: Color(0xFF49505F),
    bgMid: Color(0xFF3C4351),
    bgBottom: Color(0xFF2B313D),
    raisedHi: Color(0xFF4A5262),
    raisedMid: Color(0xFF3B4250),
    raisedLo: Color(0xFF2F3541),
    wellTop: Color(0xFF232833),
    wellMid: Color(0xFF2A303C),
    wellLo: Color(0xFF313845),
    wellEdge: Color(0x8C000000),
    edge: Color(0x8C000000),
    shadow: Color(0x730A0E16),
    shadowSoft: Color(0x4D0A0E16),
    highlight: Color(0x24FFFFFF),
    accent: Color(0xFF3D74E8),
    accentHi: Color(0xFF5B8DFF),
    accentLo: Color(0xFF1C4FB8),
    accentInk: Color(0xFF9DBDFF),
    success: Color(0xFF2F9E6A),
    danger: Color(0xFFD75B5B),
    warn: Color(0xFFD69A3F),
    warnHi: Color(0xFFEFC072),
    warnInk: Color(0xFFEFC072),
    desk: Color(0xFF242A36),
    navMid: Color(0xFF333947),
    alertHi: Color(0xFF454D5E),
    alertMid: Color(0xFF39404F),
    alertLo: Color(0xFF2F3543),
  );

  static SkTokens of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  /// Superficie rilevata (`.sk-surface`): gradiente verticale chiaro→scuro,
  /// bordo sottile e doppia ombra portata.
  BoxDecoration surface({BorderRadius? radius}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [bgTop, bgMid, bgBottom],
        stops: const [0, 0.48, 1],
      ),
      borderRadius: radius ?? BorderRadius.circular(SkRadii.lg),
      border: Border.all(color: edge),
      boxShadow: [
        BoxShadow(color: shadow, blurRadius: 34, offset: const Offset(0, 18)),
        BoxShadow(color: shadowSoft, blurRadius: 12, offset: const Offset(0, 5)),
      ],
    );
  }

  /// Variante della superficie con colore pieno (per override puntuali).
  BoxDecoration surfaceFlat(Color color, {BorderRadius? radius}) {
    return BoxDecoration(
      color: color,
      borderRadius: radius ?? BorderRadius.circular(SkRadii.lg),
      border: Border.all(color: edge),
      boxShadow: [
        BoxShadow(color: shadow, blurRadius: 34, offset: const Offset(0, 18)),
        BoxShadow(color: shadowSoft, blurRadius: 12, offset: const Offset(0, 5)),
      ],
    );
  }

  /// Pozzo/incavo (`.sk-well`): superficie premuta per input e track.
  BoxDecoration well({BorderRadius? radius}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [wellTop, wellMid, wellLo],
        stops: const [0, 0.55, 1],
      ),
      borderRadius: radius ?? BorderRadius.circular(SkRadii.md),
      border: Border.all(color: wellEdge),
    );
  }

  /// Ombra interna del pozzo (`inset 0 3px 6px`): overlay da usare come
  /// foregroundDecoration sopra [well] — il morso scuro in alto e il
  /// filo di luce sul bordo basso.
  BoxDecoration wellInnerShadow(BorderRadius radius) {
    return BoxDecoration(
      borderRadius: radius,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withValues(
            alpha: brightness == Brightness.dark ? 0.30 : 0.13,
          ),
          Colors.transparent,
          Colors.transparent,
          Colors.white.withValues(
            alpha: brightness == Brightness.dark ? 0.06 : 0.35,
          ),
        ],
        stops: const [0, 0.22, 0.92, 1],
      ),
    );
  }

  /// Alluminio opaco (`.sk-mat-aluminum`): elettro-satinato, gradiente a
  /// cinque fermi; le righe da 1px le disegna [SkBrushedPainter].
  BoxDecoration aluminum({Border? border}) {
    final isDark = brightness == Brightness.dark;
    return BoxDecoration(
      gradient: isDark
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF4A5262),
                Color(0xFF3E4654),
                Color(0xFF353D4A),
                Color(0xFF303844),
                Color(0xFF3B434F),
              ],
              stops: [0, 0.26, 0.52, 0.74, 1],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFECEFF3),
                Color(0xFFDDE2E9),
                Color(0xFFCFD6DF),
                Color(0xFFC6CDD8),
                Color(0xFFD7DDE4),
              ],
              stops: [0, 0.26, 0.52, 0.74, 1],
            ),
      border: border,
      boxShadow: [
        BoxShadow(color: shadowSoft, blurRadius: 18, offset: Offset.zero),
      ],
    );
  }

  /// Lucido superiore "sentito, non notato": overlay da usare come
  /// foregroundDecoration sopra le superfici rilevate.
  BoxDecoration gloss(BorderRadius radius) {
    final a = brightness == Brightness.dark ? 0.05 : 0.18;
    return BoxDecoration(
      borderRadius: radius,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withValues(alpha: a), Colors.transparent],
        stops: const [0, 0.35],
      ),
    );
  }

  /// Inchiostro sulla pelle (`.sk-mat-leather`: color #ecd9c3).
  static const leatherInk = Color(0xFFECD9C3);
  static const leatherInkDim = Color(0xCCECD9C3);
  static const leatherStitch = Color(0x61F0D6B0);

  /// Pelle cucita (`.sk-mat-leather`): cuoio scuro con vignettatura
  /// radiale; la cucitura a filo la disegna [SkStitchPainter].
  static BoxDecoration leather({BorderRadius? radius}) {
    return BoxDecoration(
      gradient: const RadialGradient(
        center: Alignment(-0.4, -0.64),
        radius: 1.5,
        colors: [
          Color(0xFF6D4C34),
          Color(0xFF553823),
          Color(0xFF3D2818),
          Color(0xFF33200F),
        ],
        stops: [0, 0.45, 0.8, 1],
      ),
      borderRadius: radius,
      border: Border.all(color: const Color(0x8C140C04)),
    );
  }

  /// Pozzo dei grafici (`.sk-chart`): gradiente 145° well-mid → well-top,
  /// con ombra interna profonda simulata da [chartInnerShadow].
  BoxDecoration chartWell({BorderRadius? radius}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [wellMid, wellTop],
      ),
      borderRadius: radius ?? BorderRadius.circular(SkRadii.sm),
      border: Border.all(color: wellEdge),
    );
  }

  /// Overlay che simula `inset 0 4px 10px var(--sk-shadow-deep)`.
  BoxDecoration chartInnerShadow(BorderRadius radius) {
    return BoxDecoration(
      borderRadius: radius,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withValues(
            alpha: brightness == Brightness.dark ? 0.35 : 0.18,
          ),
          Colors.transparent,
        ],
        stops: const [0, 0.16],
      ),
    );
  }

  /// Barra dei grafici (`.sk-chart__bar`): smalto accent con gradiente
  /// trasversale lo→hi→lo, filo bianco sul lato illuminato e alone accent.
  BoxDecoration chartBar({
    Axis axis = Axis.vertical,
    Color? color,
    BorderRadius? radius,
  }) {
    final c = color ?? accent;
    final lo = Color.lerp(c, Colors.black, 0.22)!;
    final hi = Color.lerp(c, Colors.white, 0.28)!;
    final vertical = axis == Axis.vertical;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: vertical ? Alignment.centerLeft : Alignment.topCenter,
        end: vertical ? Alignment.centerRight : Alignment.bottomCenter,
        colors: [lo, hi, lo],
      ),
      borderRadius: radius ??
          (vertical
              ? const BorderRadius.vertical(top: Radius.circular(4.5))
              : BorderRadius.circular(SkRadii.pill)),
      border: vertical
          ? Border(
              left: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
            )
          : Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
            ),
      boxShadow: [
        BoxShadow(
          color: c.withValues(alpha: 0.28),
          blurRadius: 6,
          offset: vertical ? const Offset(0, -2) : const Offset(0, 2),
        ),
      ],
    );
  }

  /// Superficie di alert (`.sk-alert`): gradiente più freddo, bordo tinto.
  BoxDecoration alert(Color tint, {BorderRadius? radius}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [alertHi, alertMid, alertLo],
      ),
      borderRadius: radius ?? BorderRadius.circular(SkRadii.md),
      border: Border.all(color: tint.withValues(alpha: 0.45), width: 1.2),
      boxShadow: [
        BoxShadow(color: shadowSoft, blurRadius: 12, offset: const Offset(0, 4)),
      ],
    );
  }
}

/// Cucitura a filo della pelle (`.sk-mat-leather::before`):
/// bordo tratteggiato 1.5px inset di 7px, raggio ridotto di 6px.
class SkStitchPainter extends CustomPainter {
  const SkStitchPainter({
    this.color = SkTokens.leatherStitch,
    this.inset = 7,
    this.radius = SkRadii.lg - 6,
  });

  final Color color;
  final double inset;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset(inset, inset) &
        Size(size.width - inset * 2, size.height - inset * 2);
    if (rect.isEmpty) return;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = color;

    // Tratteggio manuale (dash 5 / gap 4) lungo il perimetro arrotondato.
    final path = Path()..addRRect(rrect);
    const dash = 5.0;
    const gap = 4.0;
    for (final ui.PathMetric metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final end = (d + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(d, end), paint);
        d = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(SkStitchPainter oldDelegate) =>
      color != oldDelegate.color ||
      inset != oldDelegate.inset ||
      radius != oldDelegate.radius;
}

/// Satinatura dell'alluminio (`.sk-mat-aluminum`): repeating-linear
/// orizzontale — riga chiara 1px, riga scura 1px, 2px di pausa.
class SkBrushedPainter extends CustomPainter {
  const SkBrushedPainter({required this.isDark});
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final hi = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.035 : 0.045)
      ..strokeWidth = 1;
    final lo = Paint()
      ..color = const Color(0xFF606C7E).withValues(alpha: isDark ? 0.10 : 0.05)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), hi);
      if (y + 1 < size.height) {
        canvas.drawLine(Offset(0, y + 1), Offset(size.width, y + 1), lo);
      }
    }
  }

  @override
  bool shouldRepaint(SkBrushedPainter oldDelegate) =>
      isDark != oldDelegate.isDark;
}
