import 'package:flutter/material.dart';

import '../theme/motion.dart';
import '../theme/sk_tokens.dart';

/// Controllo segmentato sk-ui, port fedele di `.sk-segmented`:
/// - binario incavato (well): gradiente top→lo, ombra interna
///   `inset 0 2px 5px`, filo di luce sul bordo basso e sotto il binario;
/// - padding 3px, gap 2px, raggio esterno 11px, segmenti a raggio 8px;
/// - segmento attivo: pastiglia raised (hi→mid→lo) che galleggia con
///   ombra portata `0 2px 5px` e filo bianco in alto, testo accent-ink;
/// - segmenti inattivi: piatti, ink-2, testo con rilievo chiaro;
/// - transizione 160ms ease-out (--sk-dur-fast).
class SkSegmented<T> extends StatelessWidget {
  const SkSegmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.small = false,
  });

  /// Coppie valore→etichetta, nell'ordine di visualizzazione.
  final List<(T, String)> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  /// Variante `.sk-segmented--sm`.
  final bool small;

  @override
  Widget build(BuildContext context) {
    final t = SkTokens.of(context);
    final isLight = t.brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        // Binario incavato: well top→mid→lo, bordo alto scuro.
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [t.wellTop, t.wellMid, t.wellLo],
          stops: const [0, 0.55, 1],
        ),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: t.wellEdge),
        boxShadow: [
          // Filo di luce sotto il binario (`0 1px 0 rgba(255,255,255,.55)`).
          if (isLight)
            const BoxShadow(color: Color(0x8CFFFFFF), offset: Offset(0, 1)),
        ],
      ),
      // Ombra interna del pozzo (`inset 0 2px 5px`).
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: isLight ? 0.10 : 0.24),
            Colors.transparent,
            Colors.transparent,
            Colors.white.withValues(alpha: isLight ? 0.28 : 0.05),
          ],
          stops: const [0, 0.30, 0.94, 1],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < segments.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            Expanded(
              child: _Segment(
                label: segments[i].$2,
                active: segments[i].$1 == selected,
                small: small,
                onTap: () {
                  if (segments[i].$1 == selected) return;
                  AppMotion.tap();
                  onChanged(segments[i].$1);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.active,
    required this.small,
    required this.onTap,
  });

  final String label;
  final bool active;
  final bool small;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = SkTokens.of(context);
    final isLight = t.brightness == Brightness.light;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        // --sk-dur-fast: 160ms, --sk-ease-out.
        duration: AppMotion.of(context, AppMotion.dFast),
        curve: AppMotion.effects,
        padding: EdgeInsets.symmetric(
          horizontal: small ? 12 : 16,
          vertical: small ? 5 : 7.5,
        ),
        decoration: active
            ? BoxDecoration(
                // Pastiglia raised: hi→mid→lo con bordo-gradiente chiaro.
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [t.raisedHi, t.raisedMid, t.raisedLo],
                  stops: const [0, 0.48, 1],
                ),
                borderRadius: BorderRadius.circular(SkRadii.sm),
                border: Border.all(
                  color: isLight
                      ? Colors.white.withValues(alpha: 0.85)
                      : Colors.white.withValues(alpha: 0.18),
                  width: 0.8,
                ),
                boxShadow: [
                  // `0 2px 5px rgba(31,41,55,.22)` — galleggia sul binario.
                  BoxShadow(
                    color: t.shadow,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              )
            : BoxDecoration(borderRadius: BorderRadius.circular(SkRadii.sm)),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: small ? 13 : 15,
            fontWeight: active ? FontWeight.w700 : FontWeight.w600,
            color: active ? t.accentInk : t.ink2,
            shadows: isLight
                ? [
                    Shadow(
                      color: Colors.white.withValues(alpha: active ? 0.8 : 0.65),
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}
