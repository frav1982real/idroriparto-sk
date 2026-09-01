import 'package:flutter/material.dart';

import '../theme/motion.dart';
import '../theme/sk_tokens.dart';

/// Varianti di `.sk-btn` (components/button.css).
enum SkButtonVariant { neutral, primary, secondary, danger, success, ghost }

/// Dimensioni: sm 36px, md 40px, base 44px, lg 52px.
enum SkButtonSize { sm, md, base, lg }

/// Pulsante icona sk-ui (`.sk-btn--icon`): quadrato 36/40/44px,
/// stessa plastica raised del pulsante neutro.
class SkIconButton extends StatelessWidget {
  const SkIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.size = SkButtonSize.md,
    this.variant = SkButtonVariant.neutral,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final SkButtonSize size;
  final SkButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final side = switch (size) {
      SkButtonSize.sm => 36.0,
      SkButtonSize.md => 40.0,
      SkButtonSize.base => 44.0,
      SkButtonSize.lg => 52.0,
    };
    final btn = SizedBox(
      width: side,
      height: side,
      child: SkButton(
        onPressed: onPressed,
        variant: variant,
        size: size,
        expand: true,
        padding: EdgeInsets.zero,
        child: Icon(icon, size: side * 0.5),
      ),
    );
    if (tooltip == null) return btn;
    return Tooltip(message: tooltip!, child: btn);
  }
}

/// Pulsante sk-ui, port fedele di `.sk-btn`:
/// - superficie raised con gradiente hi→mid→lo e bordo-gradiente;
/// - hover: -1px e brightness 0.96;
/// - pressed: +1px con profondità invertita (fondo well, ombra interna);
/// - primary/danger/success: smalto colorato, testo bianco embossato;
/// - secondary: bordo 1.5px, riempimento leggero;
/// - ghost: solo testo accent (equivalente del link/azione inline).
class SkButton extends StatefulWidget {
  const SkButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = SkButtonVariant.neutral,
    this.size = SkButtonSize.base,
    this.icon,
    this.expand = false,
    this.padding,
  });

  const SkButton.primary({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = SkButtonSize.base,
    this.icon,
    this.expand = false,
    this.padding,
  }) : variant = SkButtonVariant.primary;

  const SkButton.secondary({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = SkButtonSize.base,
    this.icon,
    this.expand = false,
    this.padding,
  }) : variant = SkButtonVariant.secondary;

  const SkButton.danger({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = SkButtonSize.base,
    this.icon,
    this.expand = false,
    this.padding,
  }) : variant = SkButtonVariant.danger;

  const SkButton.ghost({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = SkButtonSize.base,
    this.icon,
    this.expand = false,
    this.padding,
  }) : variant = SkButtonVariant.ghost;

  final VoidCallback? onPressed;
  final Widget child;
  final SkButtonVariant variant;
  final SkButtonSize size;
  final IconData? icon;
  final bool expand;

  /// Override del padding orizzontale (es. 0 per pulsanti icona quadrati).
  final EdgeInsets? padding;

  @override
  State<SkButton> createState() => _SkButtonState();
}

class _SkButtonState extends State<SkButton> {
  bool _pressed = false;
  bool _hover = false;

  bool get _enabled => widget.onPressed != null;

  double get _height => switch (widget.size) {
        SkButtonSize.sm => 36,
        SkButtonSize.md => 40,
        SkButtonSize.base => 44,
        SkButtonSize.lg => 52,
      };

  double get _hPad => switch (widget.size) {
        SkButtonSize.sm => 14,
        SkButtonSize.md => 16,
        SkButtonSize.base => 20,
        SkButtonSize.lg => 28,
      };

  double get _fontSize => switch (widget.size) {
        SkButtonSize.sm => 14,
        SkButtonSize.md => 15,
        SkButtonSize.base => 16,
        SkButtonSize.lg => 17,
      };

  @override
  Widget build(BuildContext context) {
    final t = SkTokens.of(context);
    final v = widget.variant;
    final radius = BorderRadius.circular(
      widget.size == SkButtonSize.lg ? 10.0 : SkRadii.sm,
    );

    // Colori dello smalto per le varianti piene.
    Color? glaze;
    Color? glazeLo;
    switch (v) {
      case SkButtonVariant.primary:
        glaze = t.accent;
        glazeLo = t.accentLo;
      case SkButtonVariant.danger:
        glaze = t.danger;
        glazeLo = const Color(0xFF932F2F);
      case SkButtonVariant.success:
        glaze = t.success;
        glazeLo = const Color(0xFF186744);
      default:
        break;
    }
    final filled = glaze != null;

    BoxDecoration deco;
    Color fg;
    List<Shadow>? textShadow;

    if (v == SkButtonVariant.ghost) {
      deco = BoxDecoration(
        borderRadius: radius,
        color: _pressed
            ? t.wellMid
            : _hover
                ? t.raisedMid.withValues(alpha: 0.6)
                : Colors.transparent,
      );
      fg = t.accentInk;
    } else if (v == SkButtonVariant.secondary) {
      // .sk-btn--secondary: bordo 1.5px, fondo leggero che si riempie.
      final isDark = t.brightness == Brightness.dark;
      deco = BoxDecoration(
        borderRadius: radius,
        color: _pressed
            ? (isDark ? t.wellMid : const Color(0xA6E4EAF3))
            : _hover
                ? (isDark
                    ? t.raisedHi.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.55))
                : (isDark
                    ? t.raisedHi.withValues(alpha: 0.10)
                    : Colors.white.withValues(alpha: 0.18)),
        border: Border.all(
          color: isDark ? const Color(0x8C1B202A) : const Color(0x734A556E),
          width: 1.5,
        ),
        boxShadow: _pressed
            ? null
            : [
                BoxShadow(
                  color: t.shadowSoft,
                  blurRadius: _hover ? 10 : 2,
                  offset: Offset(0, _hover ? 4 : 1),
                ),
              ],
      );
      fg = t.ink;
    } else if (filled) {
      // Smalto colorato: hi→base→lo; pressed inverte il gradiente.
      final hi = Color.lerp(glaze, Colors.white, 0.28)!;
      deco = BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _pressed ? [glazeLo!, glaze!, hi] : [hi, glaze!, glazeLo!],
          stops: const [0, 0.52, 1],
        ),
        borderRadius: radius,
        border: Border.all(color: glazeLo.withValues(alpha: 0.7)),
        boxShadow: _pressed
            ? [
                BoxShadow(
                  color: t.shadowSoft,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: glaze.withValues(alpha: 0.30),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: t.shadowSoft,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
      );
      fg = Colors.white;
      textShadow = [
        Shadow(
          color: glazeLo.withValues(alpha: 0.5),
          offset: const Offset(0, -1),
        ),
      ];
    } else {
      // Neutro: superficie raised (plastica chiara), pressed → well.
      deco = _pressed
          ? t.well(radius: radius)
          : BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [t.raisedHi, t.raisedMid, t.raisedLo],
                stops: const [0, 0.48, 1],
              ),
              borderRadius: radius,
              border: Border.all(color: t.edge),
              boxShadow: [
                BoxShadow(
                  color: t.shadow,
                  blurRadius: _hover ? 26 : 20,
                  offset: Offset(0, _hover ? 14 : 10),
                ),
                BoxShadow(
                  color: t.shadowSoft,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            );
      fg = t.ink;
      if (t.brightness == Brightness.light) {
        textShadow = const [
          Shadow(color: Color(0xB3FFFFFF), offset: Offset(0, 1)),
        ];
      }
    }

    Widget content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: _fontSize + 3, color: fg),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: fg,
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
              shadows: textShadow,
              overflow: TextOverflow.ellipsis,
            ),
            child: widget.child,
          ),
        ),
      ],
    );

    Widget btn = AnimatedContainer(
      duration: AppMotion.of(context, AppMotion.dEffects),
      curve: AppMotion.effects,
      height: _height,
      padding: widget.padding ?? EdgeInsets.symmetric(horizontal: _hPad),
      decoration: deco,
      // Hover -1px / pressed +1px come da .sk-btn.
      transform: Matrix4.translationValues(
        0,
        _pressed
            ? 1
            : _hover && v != SkButtonVariant.ghost
                ? -1
                : 0,
        0,
      ),
      child: Center(
        widthFactor: widget.expand ? null : 1,
        child: content,
      ),
    );

    if (!_enabled) {
      btn = Opacity(opacity: 0.55, child: btn);
    }

    return MouseRegion(
      cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
        onTap: _enabled
            ? () {
                AppMotion.tap();
                widget.onPressed!();
              }
            : null,
        child: widget.expand ? btn : IntrinsicWidth(child: btn),
      ),
    );
  }
}
