import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Moto sk-ui (foundation/motion.css):
/// 160/200/240ms sui controlli, 540ms in ingresso, stagger 120ms.
/// --sk-ease-out:    cubic-bezier(0.16, 0.84, 0.44, 1)
/// --sk-ease-spring: cubic-bezier(0.34, 1.36, 0.44, 1)  (molla: k=120, c=20)
class AppMotion {
  /// --sk-ease-spring — leggero overshoot, per posizione/scala.
  static const spatial = Cubic(0.34, 1.36, 0.44, 1);
  static const spatialEmphasized = Cubic(0.34, 1.36, 0.44, 1);

  /// --sk-ease-out — decelerazione pulita, per opacità/colore.
  static const effects = Cubic(0.16, 0.84, 0.44, 1);

  static const dFast = Duration(milliseconds: 160); // --sk-dur-fast
  static const dEffects = Duration(milliseconds: 200); // --sk-dur
  static const dSpatial = Duration(milliseconds: 240); // --sk-dur-slow
  static const dSlow = Duration(milliseconds: 540); // --sk-dur-entry
  static const dStagger = Duration(milliseconds: 120); // --sk-stagger

  static bool reduce(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  static Duration of(BuildContext context, Duration raw) =>
      reduce(context) ? Duration.zero : raw;

  static void tap() => HapticFeedback.selectionClick();
  static void impact() => HapticFeedback.lightImpact();
}

/// Transizione pagina sk-ui: fade + lieve risalita (entry 540ms attenuata).
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({required WidgetBuilder builder, super.settings})
    : super(
        pageBuilder: (context, animation, secondary) => builder(context),
        transitionDuration: AppMotion.dEffects,
        reverseTransitionDuration: AppMotion.dFast,
        transitionsBuilder: (context, animation, secondary, child) {
          if (AppMotion.reduce(context)) return child;
          final eased = CurvedAnimation(
            parent: animation,
            curve: AppMotion.effects,
          );
          return FadeTransition(
            opacity: eased,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.015),
                end: Offset.zero,
              ).animate(eased),
              child: child,
            ),
          );
        },
      );
}

Future<T?> pushApp<T>(BuildContext context, Widget page) {
  AppMotion.tap();
  return Navigator.of(context).push<T>(AppPageRoute(builder: (_) => page));
}

/// Ingresso sk-ui: fade + risalita, con stagger di 120ms sull'indice
/// (comprimo lo stagger a 40ms per liste lunghe, come fa il runtime JS
/// che limita la coda di entrata).
class Appear extends StatelessWidget {
  const Appear({
    super.key,
    required this.child,
    this.index = 0,
    this.slide = 0,
  });

  final Widget child;
  final int index;
  final double slide;

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduce(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 280 + index * 40),
      curve: AppMotion.effects,
      builder: (context, t, child) {
        Widget out = Opacity(opacity: t.clamp(0.0, 1.0), child: child);
        final dy = slide != 0 ? slide : 6.0;
        out = Transform.translate(
          offset: Offset(0, (1 - t) * dy),
          child: out,
        );
        return out;
      },
      child: child,
    );
  }
}
