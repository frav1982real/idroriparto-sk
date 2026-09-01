import 'package:flutter/material.dart';

import '../theme/motion.dart';
import '../theme/sk_tokens.dart';

/// Select sk-ui, port fedele di `.sk-select`:
/// - trigger (`.sk-select__trigger`): pozzo incavato con gradiente 145°
///   well-mid→well-top, ombra interna `inset 0 3px 7px`, filo di luce
///   sotto, chevron a destra, min-height 2.65rem (42px), raggio sm;
/// - pannello (`.sk-select__content`): superficie raised hi→lo in
///   diagonale, bordo edge-bottom, ombra profonda `0 16px 34px`,
///   filo bianco in alto, padding .45rem;
/// - opzioni (`.sk-select__option`): piatte; su hover/selezione si
///   smaltano d'accent (gradiente accent-hi→accent-lo, testo bianco
///   con ombra incisa).
class SkSelect<T> extends StatefulWidget {
  const SkSelect({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final T value;

  /// Coppie valore→etichetta, nell'ordine di visualizzazione.
  final List<(T, String)> options;
  final ValueChanged<T> onChanged;

  @override
  State<SkSelect<T>> createState() => _SkSelectState<T>();
}

class _SkSelectState<T> extends State<SkSelect<T>> {
  final _link = LayerLink();
  OverlayEntry? _entry;

  bool get _open => _entry != null;

  @override
  void dispose() {
    _entry?.remove();
    _entry = null;
    super.dispose();
  }

  void _toggle() {
    if (_open) {
      _close();
    } else {
      _show();
    }
  }

  void _close() {
    _entry?.remove();
    _entry = null;
    if (mounted) setState(() {});
  }

  void _show() {
    AppMotion.tap();
    final box = context.findRenderObject()! as RenderBox;
    final width = box.size.width;
    _entry = OverlayEntry(
      builder: (overlayContext) {
        final t = SkTokens.of(context);
        return Stack(
          children: [
            // Tap fuori → chiude.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _close,
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              offset: Offset(0, box.size.height + 7), // +.45rem
              showWhenUnlinked: false,
              child: SizedBox(
                width: width < 224 ? 224 : width, // min-inline-size 14rem
                child: _SkSelectPanel<T>(
                  tokens: t,
                  options: widget.options,
                  selected: widget.value,
                  onPick: (v) {
                    _close();
                    if (v != widget.value) widget.onChanged(v);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_entry!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = SkTokens.of(context);
    final isLight = t.brightness == Brightness.light;
    final label = widget.options
        .firstWhere((o) => o.$1 == widget.value, orElse: () => widget.options.first)
        .$2;
    final radius = BorderRadius.circular(SkRadii.sm);

    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
        child: Container(
          constraints: const BoxConstraints(minHeight: 42), // 2.65rem
          padding: const EdgeInsets.fromLTRB(13, 10, 10, 10),
          decoration: BoxDecoration(
            // Trigger a pozzo: gradiente 145° well-mid → well-top.
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [t.wellMid, t.wellTop],
            ),
            borderRadius: radius,
            border: Border.all(
              color: _open ? t.accent : t.wellEdge,
              width: _open ? 2 : 1,
            ),
            boxShadow: [
              // Filo di luce sotto (`0 1px 0 var(--sk-highlight)`).
              if (isLight)
                const BoxShadow(color: Color(0x99FFFFFF), offset: Offset(0, 1)),
              if (_open)
                BoxShadow(
                  color: t.accent.withValues(alpha: 0.16),
                  spreadRadius: 4,
                ),
            ],
          ),
          // Ombra interna (`inset 0 3px 7px var(--sk-shadow)`).
          foregroundDecoration: t.wellInnerShadow(radius),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: t.ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedRotation(
                duration: AppMotion.of(context, AppMotion.dFast),
                curve: AppMotion.effects,
                turns: _open ? 0.5 : 0,
                child: Icon(Icons.expand_more, size: 20, color: t.ink3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkSelectPanel<T> extends StatelessWidget {
  const _SkSelectPanel({
    required this.tokens,
    required this.options,
    required this.selected,
    required this.onPick,
  });

  final SkTokens tokens;
  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onPick;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.of(context, AppMotion.dFast),
      curve: AppMotion.effects,
      builder: (context, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - v) * -4),
          child: child,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(7), // .45rem
        decoration: BoxDecoration(
          // Pannello raised: gradiente 145° hi→lo, bordo edge, ombra profonda.
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [t.raisedHi, t.raisedLo],
          ),
          borderRadius: BorderRadius.circular(SkRadii.sm),
          border: Border.all(color: t.edge),
          boxShadow: [
            BoxShadow(
              color: t.shadow,
              blurRadius: 34,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        // Filo bianco in alto (`inset 0 1px 0 var(--sk-highlight)`).
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SkRadii.sm),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(
                alpha: t.brightness == Brightness.light ? 0.55 : 0.10,
              ),
              Colors.transparent,
            ],
            stops: const [0, 0.05],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final o in options)
              _SkOption(
                label: o.$2,
                selected: o.$1 == selected,
                tokens: t,
                onTap: () => onPick(o.$1),
              ),
          ],
        ),
      ),
    );
  }
}

class _SkOption extends StatefulWidget {
  const _SkOption({
    required this.label,
    required this.selected,
    required this.tokens,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final SkTokens tokens;
  final VoidCallback onTap;

  @override
  State<_SkOption> createState() => _SkOptionState();
}

class _SkOptionState extends State<_SkOption> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final lit = widget.selected || _hover;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          AppMotion.tap();
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: AppMotion.of(context, AppMotion.dFast),
          curve: AppMotion.effects,
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.6), // .35rem
            gradient: lit
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [t.accentHi, t.accentLo],
                  )
                : null,
          ),
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.8,
              fontWeight: FontWeight.w500,
              color: lit ? Colors.white : t.ink,
              shadows: lit
                  ? const [
                      Shadow(color: Color(0x40000000), offset: Offset(0, -1)),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
