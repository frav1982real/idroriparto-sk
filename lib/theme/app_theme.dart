import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'sk_tokens.dart';

/// Tinte per le unità: la palette semantica di sk-ui
/// (accent, success, warn, danger — saturation <= 80%).
class SchemeInk {
  static Color forUnit(ColorScheme s, String id) {
    final t = s.brightness == Brightness.dark ? SkTokens.dark : SkTokens.light;
    final palette = <Color>[t.accent, t.success, t.warn, t.danger];
    return palette[id.hashCode.abs() % palette.length];
  }
}

/// Tema dell'app costruito interamente sui token di sk-ui
/// (packages/ui/src/foundation/tokens.css). Niente Material You:
/// superfici plastiche, pozzo/incavo per gli input, accent smaltato.
class AppTheme {
  static ThemeData light() => _from(SkTokens.light);
  static ThemeData dark() => _from(SkTokens.dark);

  /// Mappa i token sk-ui sui ruoli di [ColorScheme] usati nelle schermate.
  static ColorScheme _scheme(SkTokens t) {
    final isDark = t.brightness == Brightness.dark;
    return ColorScheme(
      brightness: t.brightness,
      // Accent — plastica smaltata blu.
      primary: t.accent,
      onPrimary: Colors.white,
      primaryContainer: isDark ? const Color(0xFF2A3D63) : const Color(0xFFDCE7FB),
      onPrimaryContainer: t.accentInk,
      // Secondario: inchiostro attenuato + superficie premuta (well).
      secondary: t.ink2,
      onSecondary: isDark ? t.wellTop : Colors.white,
      secondaryContainer: t.wellMid,
      onSecondaryContainer: t.accentInk,
      // Terziario: semantica success (stati "chiusa", toni positivi).
      tertiary: t.success,
      onTertiary: Colors.white,
      tertiaryContainer: isDark ? const Color(0xFF4A4433) : const Color(0xFFF7E9CF),
      onTertiaryContainer: t.warnInk,
      error: t.danger,
      onError: Colors.white,
      errorContainer: isDark ? const Color(0xFF52333A) : const Color(0xFFF6DCDC),
      onErrorContainer: isDark ? const Color(0xFFEE9090) : const Color(0xFF8F2B2B),
      // Scrivania e superfici.
      surface: t.desk,
      onSurface: t.ink,
      onSurfaceVariant: t.ink3,
      surfaceContainerLowest: t.raisedHi,
      surfaceContainerLow: t.raisedMid,
      surfaceContainer: t.navMid,
      surfaceContainerHigh: t.alertMid,
      surfaceContainerHighest: t.wellMid,
      outline: isDark ? const Color(0xFF5B6478) : const Color(0xFF8B94A8),
      outlineVariant: isDark ? const Color(0xFF48505F) : const Color(0xFFC3CBD9),
      shadow: t.shadow,
      scrim: Colors.black54,
      inverseSurface: isDark ? const Color(0xFFEEF2F8) : const Color(0xFF2B313D),
      onInverseSurface: isDark ? const Color(0xFF2B313D) : const Color(0xFFEEF2F8),
      inversePrimary: t.accentHi,
    );
  }

  static ThemeData _from(SkTokens t) {
    final scheme = _scheme(t);
    final isDark = t.brightness == Brightness.dark;
    final text = textTheme(t);
    // Raggi sk-ui: base 8px, controlli sm, contenitori md/lg.
    final rSm = BorderRadius.circular(SkRadii.sm);
    final rMd = BorderRadius.circular(SkRadii.md);
    final rLg = BorderRadius.circular(SkRadii.lg);
    final rXl = BorderRadius.circular(SkRadii.xl);

    return ThemeData(
      useMaterial3: true,
      brightness: t.brightness,
      colorScheme: scheme,
      // Nimbus Sans L dappertutto (file URW inclusi negli asset).
      fontFamily: 'Nimbus Sans L',
      fontFamilyFallback: const ['Helvetica', 'Arial', 'Roboto'],
      textTheme: text,
      scaffoldBackgroundColor: t.desk,
      // sk-ui non ha ripple materiale: feedback di pressione secco.
      splashFactory: NoSplash.splashFactory,
      highlightColor: t.wellTop.withValues(alpha: 0.45),
      visualDensity: VisualDensity.standard,
      dividerColor: t.edge,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: t.desk,
        foregroundColor: t.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: text.titleLarge,
      ),
      // Card "subtly rounded" (8px) — la superficie plastica vera la dà AppCard.
      cardTheme: CardThemeData(
        color: t.bgMid,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: rSm),
      ),
      // Chip = pastiglia rilevata sk (raised, bordo sottile, raggio pill).
      chipTheme: ChipThemeData(
        side: BorderSide(color: t.edge),
        backgroundColor: t.raisedMid,
        selectedColor: t.wellMid,
        checkmarkColor: t.accentInk,
        labelStyle: text.labelLarge?.copyWith(color: t.ink),
        secondaryLabelStyle: text.labelLarge?.copyWith(color: t.accentInk),
        shape: const StadiumBorder(),
        elevation: 1,
        shadowColor: t.shadowSoft,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      // Input = `.sk-input`: il pozzo incavato vero (gradiente + ombra
      // interna + focus ring) lo disegna il widget SkInputWell, che avvolge
      // ogni campo. Qui il decoratore Material resta trasparente.
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        isDense: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        // Label sopra il campo (la disegna ItField): qui resta solo il hint.
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelStyle: text.bodyMedium?.copyWith(color: const Color(0xFF8A94A6)),
        hintStyle: text.bodyMedium?.copyWith(color: const Color(0xFF8A94A6)),
        errorStyle: text.bodySmall?.copyWith(
          color: t.danger,
          fontWeight: FontWeight.w600,
        ),
      ),
      // sk-btn--primary: smalto blu, ombra colorata, raggio 8px, testo embossato.
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.pressed) ? t.accentLo : t.accent,
          ),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          overlayColor: WidgetStatePropertyAll(
            Colors.white.withValues(alpha: 0.06),
          ),
          elevation: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.pressed) ? 0.0 : 6.0,
          ),
          shadowColor: WidgetStatePropertyAll(t.accent.withValues(alpha: 0.45)),
          minimumSize: const WidgetStatePropertyAll(Size(48, 52)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: rSm,
              side: BorderSide(color: t.accentLo.withValues(alpha: 0.6)),
            ),
          ),
          textStyle: WidgetStatePropertyAll(
            text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      // sk-btn--secondary: bordo 1.5px, fondo quasi trasparente.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(t.ink),
          backgroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.pressed)) {
              return t.wellMid;
            }
            if (s.contains(WidgetState.hovered)) {
              return t.raisedHi.withValues(alpha: isDark ? 0.25 : 0.55);
            }
            return t.raisedHi.withValues(alpha: isDark ? 0.10 : 0.18);
          }),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          side: WidgetStatePropertyAll(
            BorderSide(
              color: isDark
                  ? const Color(0x8C1B202A)
                  : const Color(0x734A556E),
              width: 1.5,
            ),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(48, 52)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: rSm),
          ),
          textStyle: WidgetStatePropertyAll(
            text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: t.accentInk,
          minimumSize: const Size(48, 44),
          shape: RoundedRectangleBorder(borderRadius: rSm),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      // FAB come push-button primario sk: smalto, raggio md.
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: t.accent,
        foregroundColor: Colors.white,
        elevation: 6,
        highlightElevation: 0,
        splashColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: rMd,
          side: BorderSide(color: t.accentLo.withValues(alpha: 0.6)),
        ),
        extendedTextStyle:
            text.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      // Navbar sk: plancia rilevata, voce attiva premuta nel pozzo.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: t.navMid,
        indicatorColor: t.wellMid,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: rMd,
          side: BorderSide(color: t.wellEdge),
        ),
        elevation: 0,
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? t.accentInk : t.ink3,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return text.labelMedium!.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? t.ink : t.ink3,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: t.navMid,
        indicatorColor: t.wellMid,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: rMd,
          side: BorderSide(color: t.wellEdge),
        ),
        selectedIconTheme: IconThemeData(color: t.accentInk),
        unselectedIconTheme: IconThemeData(color: t.ink3),
        selectedLabelTextStyle:
            text.labelMedium!.copyWith(fontWeight: FontWeight.w700, color: t.ink),
        unselectedLabelTextStyle: text.labelMedium!.copyWith(color: t.ink3),
      ),
      dividerTheme: DividerThemeData(color: t.edge, space: 1),
      // Toast sk: superficie scura rilevata, raggio md.
      // SnackBar (se mai usato direttamente): smalto grafite `.sk-toast`.
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF232A37),
        contentTextStyle:
            text.bodyMedium?.copyWith(color: const Color(0xFFF1F5FB)),
        elevation: 14,
        shape: RoundedRectangleBorder(
          borderRadius: rMd,
          side: BorderSide(color: Colors.black.withValues(alpha: 0.5)),
        ),
      ),
      // Dialog sk: pannello rilevato, raggio lg (18px), bordo chiaro in alto.
      dialogTheme: DialogThemeData(
        backgroundColor: t.bgMid,
        elevation: 18,
        shadowColor: t.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: rLg,
          side: BorderSide(color: t.edge),
        ),
        titleTextStyle: text.headlineSmall,
        contentTextStyle: text.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.bgMid,
        elevation: 18,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(SkRadii.xl)),
          side: BorderSide(color: t.edge),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: t.ink3,
        textColor: t.ink,
        shape: RoundedRectangleBorder(borderRadius: rSm),
      ),
      // Segmented control sk: binario incavato, segmento attivo rilevato.
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.comfortable,
          backgroundColor: WidgetStateProperty.resolveWith((s) {
            return s.contains(WidgetState.selected) ? t.raisedHi : t.wellMid;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((s) {
            return s.contains(WidgetState.selected) ? t.accentInk : t.ink3;
          }),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          side: WidgetStatePropertyAll(BorderSide(color: t.wellEdge)),
          textStyle: WidgetStateProperty.resolveWith((s) {
            return text.labelLarge?.copyWith(
              fontWeight: s.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
            );
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: rSm),
          ),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(t.bgTop),
          elevation: const WidgetStatePropertyAll(12),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: rMd,
              side: BorderSide(color: t.edge),
            ),
          ),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: t.bgMid,
        headerBackgroundColor: t.accent,
        headerForegroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: rXl,
          side: BorderSide(color: t.edge),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: t.accent,
        linearTrackColor: t.wellMid,
        circularTrackColor: t.wellMid,
      ),
      // Switch sk (`.sk-switch`): binario incavato (well), pomello raised;
      // acceso il binario si smalta d'accent.
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll(t.raisedHi),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.accent : t.wellTop,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? t.accentLo.withValues(alpha: 0.7)
              : t.wellEdge,
        ),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      // Checkbox sk: pozzo quadrato raggio 8px, spunta accent.
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.accent : t.wellMid,
        ),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: BorderSide(color: t.wellEdge, width: 1.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SkRadii.sm / 2),
        ),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      // Radio sk: foro incavato, pallino accent.
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.accent : t.ink3,
        ),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      // Slider sk (`.sk-slider`): binario incavato, pomello plastica raised.
      sliderTheme: SliderThemeData(
        activeTrackColor: t.accent,
        inactiveTrackColor: t.wellTop,
        thumbColor: t.raisedHi,
        overlayColor: t.accent.withValues(alpha: 0.12),
        trackHeight: 8,
      ),
      // Tabelle sk (`.sk-table`): testa raised, righe separate dal bordo token.
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(t.raisedMid),
        dataRowColor: const WidgetStatePropertyAll(Colors.transparent),
        dividerThickness: 1,
        headingTextStyle: text.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: t.ink2,
        ),
        dataTextStyle: text.bodyMedium,
        decoration: BoxDecoration(
          border: Border.all(color: t.edge),
          borderRadius: BorderRadius.circular(SkRadii.sm),
        ),
      ),
      // Tooltip sk: smalto grafite come il toast.
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3B4454), Color(0xFF232A37), Color(0xFF1A2029)],
            stops: [0, 0.55, 1],
          ),
          borderRadius: BorderRadius.circular(SkRadii.sm),
          border: Border.all(color: Colors.black.withValues(alpha: 0.5)),
        ),
        textStyle: const TextStyle(
          color: Color(0xFFF1F5FB),
          fontSize: 12.5,
          fontFamily: 'Nimbus Sans L',
          fontFamilyFallback: ['Helvetica', 'Arial', 'Roboto'],
        ),
      ),
      // PopupMenu / menu contestuali: pannello sk rilevato.
      popupMenuTheme: PopupMenuThemeData(
        color: t.bgTop,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SkRadii.md),
          side: BorderSide(color: t.edge),
        ),
        textStyle: text.bodyMedium,
      ),
      // Scrollbar sk: pomello raised su binario trasparente.
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(t.ink3.withValues(alpha: 0.5)),
        radius: const Radius.circular(SkRadii.pill),
        thickness: const WidgetStatePropertyAll(6),
      ),
    );
  }

  /// Tipografia sk-ui: system UI stack (design.md), niente font brandizzati.
  /// Gerarchia data dal peso, non dalla famiglia.
  static TextTheme textTheme(SkTokens t) {
    TextStyle s(
      double size,
      FontWeight w,
      Color color, {
      double height = 1.25,
      double ls = 0,
    }) {
      return TextStyle(
        fontFamily: 'Nimbus Sans L',
        fontFamilyFallback: const ['Helvetica', 'Arial', 'Roboto'],
        fontSize: size,
        fontWeight: w,
        height: height,
        letterSpacing: ls,
        color: color,
      );
    }

    return TextTheme(
      displayLarge: s(44, FontWeight.w800, t.ink, height: 1.1, ls: -0.7),
      displayMedium: s(34, FontWeight.w800, t.ink, height: 1.1, ls: -0.6),
      headlineMedium: s(28, FontWeight.w700, t.ink, height: 1.12, ls: -0.4),
      headlineSmall: s(22, FontWeight.w700, t.ink, height: 1.15, ls: -0.3),
      titleLarge: s(20, FontWeight.w700, t.ink, ls: -0.2),
      titleMedium: s(16, FontWeight.w600, t.ink),
      titleSmall: s(14, FontWeight.w600, t.ink),
      bodyLarge: s(16, FontWeight.w400, t.ink, height: 1.45),
      bodyMedium: s(14, FontWeight.w400, t.ink, height: 1.45),
      bodySmall: s(12.5, FontWeight.w400, t.ink3, height: 1.4),
      labelLarge: s(13.5, FontWeight.w600, t.ink),
      labelMedium: s(12, FontWeight.w600, t.ink3, ls: 0.4),
    );
  }
}
