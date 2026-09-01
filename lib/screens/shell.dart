import 'package:flutter/material.dart';

import '../data/store.dart';
import '../theme/motion.dart';
import '../theme/sk_tokens.dart';
import '../widgets/widgets.dart';
import 'bollette_screens.dart';
import 'dashboard_screen.dart';
import 'letture_screens.dart';
import 'settings_screen.dart';
import 'unita_screens.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  static const _dest = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.apartment_outlined, Icons.apartment_rounded, 'Unità'),
    (Icons.speed_outlined, Icons.speed_rounded, 'Letture'),
    (Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Bollette'),
    (Icons.tune_outlined, Icons.tune_rounded, 'Altro'),
  ];

  void _go(int i) {
    if (i == index) return;
    AppMotion.tap();
    setState(() => index = i);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;
    final t = SkTokens.of(context);
    final pages = const [
      DashboardScreen(),
      UnitaListScreen(),
      LettureScreen(),
      BolletteListScreen(),
      SettingsScreen(),
    ];

    final body = AnimatedSwitcher(
      duration: AppMotion.of(context, AppMotion.dEffects),
      switchInCurve: AppMotion.effects,
      switchOutCurve: AppMotion.effects,
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: KeyedSubtree(key: ValueKey(index), child: pages[index]),
    );

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            // Sidebar in alluminio opaco (`.sk-mat-aluminum`):
            // elettro-satinato, righe di satinatura da 1px, luce diffusa.
            DecoratedBox(
              decoration: t.aluminum(
                border: Border(right: BorderSide(color: t.edge)),
              ),
              child: CustomPaint(
                painter: SkBrushedPainter(
                  isDark: t.brightness == Brightness.dark,
                ),
                child: SizedBox(
                width: 236,
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 22, 16, 18),
                        child: Row(
                          children: [
                            const LogoMark(size: 40),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'IdroRiparto',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    StoreScope.of(context).condominio?.nome ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      for (var i = 0; i < _dest.length; i++)
                        _RailItem(
                          icon: index == i ? _dest[i].$2 : _dest[i].$1,
                          label: _dest[i].$3,
                          selected: index == i,
                          onTap: () => _go(i),
                        ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Dati solo su questo dispositivo',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              ),
            ),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      body: body,
      // Navbar in alluminio opaco (`.sk-mat-aluminum`): elettro-satinato,
      // righe di satinatura da 1px, bordo superiore e luce diffusa.
      bottomNavigationBar: DecoratedBox(
        decoration: t.aluminum(
          border: Border(top: BorderSide(color: t.edge)),
        ),
        child: CustomPaint(
          painter: SkBrushedPainter(
            isDark: t.brightness == Brightness.dark,
          ),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            selectedIndex: index,
            onDestinationSelected: _go,
            destinations: [
              for (final d in _dest)
                NavigationDestination(
                  icon: Icon(d.$1),
                  selectedIcon: Icon(d.$2),
                  label: d.$3,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = SkTokens.of(context);
    // Voce sidebar sk: la voce attiva è "premuta" dentro un pozzo (well),
    // le altre sono piatte sulla plancia.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.of(context, AppMotion.dEffects),
          curve: AppMotion.effects,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: selected
              ? t.well(radius: BorderRadius.circular(SkRadii.md))
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(SkRadii.md),
                ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? t.accentInk : t.ink3,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? t.ink : t.ink2,
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
