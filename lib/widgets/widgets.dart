import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/motion.dart';
import '../theme/sk_tokens.dart';
import '../utils/format.dart';
import 'sk_button.dart';

export 'sk_button.dart';
export 'sk_segmented.dart';
export 'sk_select.dart';

class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 56});
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: Image.asset(
        'assets/brand/logo_source.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        // Downscale di qualità: senza, Flutter usa FilterQuality.low
        // e il logo appare sfocato alle taglie piccole.
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                letterSpacing: 1.05,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Card sk-ui (`.sk-surface` + `.sk-card`): superficie plastica rilevata
/// con gradiente verticale, bordo sottile, doppia ombra e lucido superiore.
/// Se `onTap` è presente si comporta come superficie interattiva: alla
/// pressione la profondità si inverte (stato `.sk-pressed`).
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = SkTokens.of(context);
    final radius = BorderRadius.circular(SkRadii.lg);

    final BoxDecoration deco;
    if (_pressed && widget.onTap != null) {
      // Stato premuto: superficie pozzo, ombra interna simulata dal well.
      deco = t.well(radius: radius);
    } else if (widget.color != null) {
      deco = t.surfaceFlat(widget.color!, radius: radius);
    } else {
      deco = t.surface(radius: radius);
    }

    final card = AnimatedContainer(
      duration: AppMotion.of(context, AppMotion.dEffects),
      curve: AppMotion.effects,
      decoration: deco,
      foregroundDecoration: _pressed ? null : t.gloss(radius),
      transform: Matrix4.translationValues(0, _pressed ? 1 : 0, 0),
      child: Padding(padding: widget.padding, child: widget.child),
    );

    if (widget.onTap == null) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () {
        AppMotion.tap();
        widget.onTap!();
      },
      child: card,
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.hint,
    this.icon,
    this.tone,
  });

  final String label;
  final String value;
  final String? hint;
  final IconData? icon;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = SkTokens.of(context);
    final c = tone ?? scheme.primary;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                // Pastiglia incavata (well) con icona tinta accent.
                Container(
                  width: 32,
                  height: 32,
                  decoration: t.well(
                    radius: BorderRadius.circular(SkRadii.sm),
                  ),
                  child: Icon(icon, size: 18, color: t.accentInk),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: c,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(
              hint!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class MetricGrid extends StatelessWidget {
  const MetricGrid({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final cols = box.maxWidth > 720 ? 4 : 2;
        const gap = 12.0;
        final w = (box.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < children.length; i++)
              Appear(
                index: i,
                child: SizedBox(width: w, child: children[i]),
              ),
          ],
        );
      },
    );
  }
}

class MoneyText extends StatelessWidget {
  const MoneyText(
    this.amount, {
    super.key,
    this.style,
    this.color,
    this.big = false,
  });
  final num amount;
  final TextStyle? style;
  final Color? color;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final base = big
        ? Theme.of(context).textTheme.headlineMedium
        : Theme.of(context).textTheme.titleMedium;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Text(
        euro(amount),
        maxLines: 1,
        style: (style ?? base)?.copyWith(
          color: color ?? Theme.of(context).colorScheme.onSurface,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class InternoAvatar extends StatelessWidget {
  const InternoAvatar({super.key, required this.unita, this.size = 44});
  final UnitaImmobiliare unita;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = SkTokens.of(context);
    final c = SchemeInk.forUnit(scheme, unita.id);
    // Placca rilevata sk con bordo tinto: l'interno inciso sopra.
    return AnimatedContainer(
      duration: AppMotion.of(context, AppMotion.dSpatial),
      curve: AppMotion.spatial,
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [t.raisedHi, t.raisedMid, t.raisedLo],
          stops: const [0, 0.48, 1],
        ),
        borderRadius: BorderRadius.circular(SkRadii.sm),
        border: Border.all(color: c.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: t.shadowSoft,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        unita.interno,
        maxLines: 1,
        style: TextStyle(
          color: c,
          fontSize: size * 0.34,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.color,
    this.icon,
  });
  final String label;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = SkTokens.of(context);
    final c = color ?? scheme.primary;
    // Badge sk: pastiglia rilevata con bordo tinto e leggera ombra portata.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 28),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [t.raisedHi, t.raisedLo],
          ),
          borderRadius: BorderRadius.circular(SkRadii.pill),
          border: Border.all(color: c.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: t.shadowSoft,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13, color: c),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WarningBanner extends StatelessWidget {
  const WarningBanner({super.key, required this.messages});
  final List<String> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) return const SizedBox.shrink();
    final t = SkTokens.of(context);
    // Alert sk (`.sk-alert--warning`): superficie di avviso con bordo tinto.
    return DecoratedBox(
      decoration: t.alert(t.warn, radius: BorderRadius.circular(SkRadii.md)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: t.warnInk),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Da verificare',
                    style: TextStyle(
                      color: t.warnInk,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final m in messages)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '· $m',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: t.warnInk,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.onLeather = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Se true, i testi usano l'inchiostro caldo della pelle
  /// (`.sk-mat-leather`: color #ecd9c3).
  final bool onLeather;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = SkTokens.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Appear(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Empty state sk: icona dentro un pozzo incavato.
                Container(
                  width: 76,
                  height: 76,
                  decoration: onLeather
                      ? BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(SkRadii.lg),
                          border: Border.all(color: SkTokens.leatherStitch),
                        )
                      : t.well(radius: BorderRadius.circular(SkRadii.lg)),
                  child: Icon(
                    icon,
                    size: 34,
                    color: onLeather ? SkTokens.leatherInkDim : t.ink3,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: onLeather ? SkTokens.leatherInk : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: onLeather
                        ? SkTokens.leatherInkDim
                        : scheme.onSurfaceVariant,
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 20),
                  SkButton.primary(
                    onPressed: onAction,
                    child: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pozzo di input (`.sk-input`): incavo vero — gradiente well-top→lo
/// (scuro in alto, dove l'ombra interna morde), bordo alto scuro e filo
/// di luce sul fondo, focus ring accent 2px con alone.
/// Avvolge TextField, Dropdown o qualsiasi controllo di form.
class SkInputWell extends StatefulWidget {
  const SkInputWell({super.key, required this.child});
  final Widget child;

  @override
  State<SkInputWell> createState() => _SkInputWellState();
}

class _SkInputWellState extends State<SkInputWell> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final t = SkTokens.of(context);
    final radius = BorderRadius.circular(SkRadii.sm);
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: AppMotion.of(context, AppMotion.dEffects),
        curve: AppMotion.effects,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [t.wellTop, t.wellMid, t.wellLo],
            stops: const [0, 0.6, 1],
          ),
          borderRadius: radius,
          border: Border.all(
            color: _focused ? t.accent : t.wellEdge,
            width: _focused ? 2 : 1,
          ),
          boxShadow: [
            // Filo di luce sotto il pozzo (`0 1px 0 rgba(255,255,255,.6)`).
            if (t.brightness == Brightness.light)
              const BoxShadow(color: Color(0x99FFFFFF), offset: Offset(0, 1)),
            // Alone del focus ring (`0 0 0 4px rgba(accent,.14)`).
            if (_focused)
              BoxShadow(
                color: t.accent.withValues(alpha: 0.16),
                spreadRadius: 4,
              ),
          ],
        ),
        foregroundDecoration: t.wellInnerShadow(radius),
        child: widget.child,
      ),
    );
  }
}

/// Wrapper `.sk-field` per controlli arbitrari (dropdown, stepper…):
/// etichetta incisa sopra, controllo sotto.
class SkField extends StatelessWidget {
  const SkField({super.key, required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = SkTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.28,
              color: t.brightness == Brightness.dark
                  ? t.ink2
                  : const Color(0xFF334155),
              shadows: t.brightness == Brightness.light
                  ? const [Shadow(color: Color(0xC7FFFFFF), offset: Offset(0, 1))]
                  : null,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class ItField extends StatelessWidget {
  const ItField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.suffix,
    this.prefixIcon,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.onChanged,
    this.enabled = true,
    this.autofocus = false,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? suffix;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final t = SkTokens.of(context);
    // `.sk-field`: label sopra il campo (etichetta incisa), input a pozzo,
    // niente floating label Material.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.28,
              color: t.brightness == Brightness.dark ? t.ink2 : const Color(0xFF334155),
              shadows: t.brightness == Brightness.light
                  ? const [Shadow(color: Color(0xC7FFFFFF), offset: Offset(0, 1))]
                  : null,
            ),
          ),
        ),
        // Il campo vive dentro un pozzo incavato vero (`.sk-input`).
        SkInputWell(
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            maxLines: maxLines,
            onChanged: onChanged,
            enabled: enabled,
            autofocus: autofocus,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hint,
              suffixText: suffix,
              prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
            ),
          ),
        ),
      ],
    );
  }
}

class ShareBar extends StatelessWidget {
  const ShareBar({super.key, required this.parts});
  final List<({Color color, double value})> parts;

  @override
  Widget build(BuildContext context) {
    final tot = parts.fold<double>(0, (a, b) => a + b.value);
    final t = SkTokens.of(context);
    // Barra sk: i segmenti corrono dentro un binario incavato (well).
    return Container(
      decoration: t.well(radius: BorderRadius.circular(SkRadii.pill)),
      padding: const EdgeInsets.all(2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SkRadii.pill),
        child: SizedBox(
          height: 12,
          child: Row(
            children: [
              for (final p in parts)
                if (p.value > 0)
                  Expanded(
                    flex: (p.value / (tot <= 0 ? 1 : tot) * 1000)
                        .round()
                        .clamp(1, 1000),
                    child: AnimatedContainer(
                      duration: AppMotion.of(context, AppMotion.dSpatial),
                      curve: AppMotion.spatial,
                      color: p.color,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class UnitShareChart extends StatelessWidget {
  const UnitShareChart({super.key, required this.righe});
  final List<RigaRiparto> righe;

  @override
  Widget build(BuildContext context) {
    if (righe.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final tokens = SkTokens.of(context);
    final maxV = righe
        .map((e) => e.totale)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final wellRadius = BorderRadius.circular(SkRadii.sm);
    // `.sk-chart` in orizzontale: tutte le barre vivono in un unico pozzo
    // incassato (gradiente 145°, ombra interna), ogni barra è
    // `.sk-chart__bar` — smalto lo→hi→lo, filo bianco sul lato in luce.
    return Container(
      decoration: tokens.chartWell(radius: wellRadius),
      foregroundDecoration: tokens.chartInnerShadow(wellRadius),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        children: [
        for (var i = 0; i < righe.length; i++)
          Appear(
            index: i,
            slide: 10,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      righe[i].interno,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: 0,
                        end: maxV <= 0
                            ? 0
                            : (righe[i].totale / maxV).clamp(0, 1),
                      ),
                      duration: AppMotion.of(context, AppMotion.dSpatial),
                      curve: AppMotion.spatial,
                      builder: (context, t, _) {
                        final tok = SkTokens.of(context);
                        final fill = SchemeInk.forUnit(
                          scheme,
                          righe[i].unitaId,
                        );
                        // Barra `.sk-chart__bar` orizzontale: raggio .28rem
                        // sul lato che cresce, smalto lo→hi→lo trasversale.
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: t <= 0 ? 0.001 : t,
                            child: Container(
                              height: 18,
                              decoration: tok.chartBar(
                                axis: Axis.horizontal,
                                color: fill,
                                radius: const BorderRadius.horizontal(
                                  right: Radius.circular(4.5),
                                  left: Radius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 84,
                    child: Text(
                      euro(righe[i].totale),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFeatures: [FontFeature.tabularFigures()],
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip di scelta sk: pastiglia rilevata (raised); quando selezionata
/// si "preme" nel pozzo con testo accent — coerente con segmented-control.
class SkChoiceChip extends StatelessWidget {
  const SkChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final t = SkTokens.of(context);
    final radius = BorderRadius.circular(SkRadii.pill);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        AppMotion.tap();
        onSelected();
      },
      child: AnimatedContainer(
        duration: AppMotion.of(context, AppMotion.dEffects),
        curve: AppMotion.effects,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: selected
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
                    color: t.shadowSoft,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
        transform: Matrix4.translationValues(0, selected ? 1 : 0, 0),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? t.accentInk : t.ink,
          ),
        ),
      ),
    );
  }
}

class StatoChip extends StatelessWidget {
  const StatoChip(this.stato, {super.key});
  final StatoBolletta stato;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (stato) {
      StatoBolletta.bozza => scheme.onSurfaceVariant,
      StatoBolletta.calcolata => scheme.primary,
      StatoBolletta.chiusa => scheme.tertiary,
    };
    return StatusPill(label: stato.label, color: color);
  }
}

Future<DateTime?> pickDate(
  BuildContext context, {
  DateTime? initial,
  DateTime? first,
  DateTime? last,
}) {
  final now = DateTime.now();
  return showDatePicker(
    context: context,
    initialDate: initial ?? now,
    firstDate: first ?? DateTime(now.year - 12),
    lastDate: last ?? DateTime(now.year + 2),
    locale: const Locale('it', 'IT'),
  );
}

/// Toast sk-ui (`.sk-toast`): smalto grafite centrato in basso, entra
/// con la molla (300ms sk-ease-spring) da +16px, icona success-hi,
/// testo con ombra incisa. Overlay puro, niente SnackBar Material.
void showToast(BuildContext context, String msg, {IconData? icon}) {
  final overlay = Overlay.of(context);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _SkToast(
      message: msg,
      icon: icon ?? Icons.check_circle,
      onDismissed: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _SkToast extends StatefulWidget {
  const _SkToast({
    required this.message,
    required this.icon,
    required this.onDismissed,
  });
  final String message;
  final IconData icon;
  final VoidCallback onDismissed;

  @override
  State<_SkToast> createState() => _SkToastState();
}

class _SkToastState extends State<_SkToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _in;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _in = CurvedAnimation(
      parent: _c,
      curve: AppMotion.spatial, // --sk-ease-spring
      reverseCurve: AppMotion.effects,
    );
    _c.forward();
    Future<void>.delayed(const Duration(milliseconds: 2800), () async {
      if (!mounted) return;
      await _c.reverse();
      widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 24 + MediaQuery.paddingOf(context).bottom,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _in,
          builder: (context, child) {
            return Opacity(
              opacity: _in.value.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, (1 - _in.value) * 16),
                child: child,
              ),
            );
          },
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                // Smalto grafite: #3b4454 → #232a37 → #1a2029.
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF3B4454),
                    Color(0xFF232A37),
                    Color(0xFF1A2029),
                  ],
                  stops: [0, 0.55, 1],
                ),
                borderRadius: BorderRadius.circular(SkRadii.md),
                border: Border.all(color: Colors.black.withValues(alpha: 0.5)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x660A0E16),
                    blurRadius: 36,
                    offset: Offset(0, 18),
                  ),
                ],
              ),
              // Filo di luce interno in alto.
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SkRadii.md),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.12],
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 18, color: const Color(0xFF63C696)),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      widget.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFF1F5FB),
                        fontSize: 15,
                        shadows: [
                          Shadow(
                            color: Color(0x800A0E16),
                            offset: Offset(0, 1),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MaxWidth extends StatelessWidget {
  const MaxWidth({super.key, required this.child, this.width = 1120});
  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: child,
      ),
    );
  }
}
