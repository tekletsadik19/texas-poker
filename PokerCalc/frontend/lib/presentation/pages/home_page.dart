import 'package:flutter/material.dart';
import '../widgets/playing_card.dart';
import 'best_hand_page.dart';
import 'compare_page.dart';
import 'probability_page.dart';

class PokerHomePage extends StatefulWidget {
  const PokerHomePage({super.key});

  @override
  State<PokerHomePage> createState() => _PokerHomePageState();
}

class _PokerHomePageState extends State<PokerHomePage> {
  int _selectedIndex = 0;

  static const _pages = [BestHandPage(), ComparePage(), ProbabilityPage()];

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        titleSpacing: 16,
        title: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                const PlayingCard(cardId: 'AS', width: 20),
                Positioned(
                  left: 10,
                  top: 0,
                  child: const PlayingCard(cardId: 'KH', width: 20),
                ),
              ],
            ),
            const SizedBox(width: 28),
            const Text(
              'PokerCalc',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          if (!isSmallScreen) ...[
            _statusIndicator('GKE CLUSTER', const Color(0xFF27AE60)),
            const SizedBox(width: 16),
          ],
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            extended: !isSmallScreen && MediaQuery.of(context).size.width > 900,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            labelType:
                (!isSmallScreen && MediaQuery.of(context).size.width > 900)
                ? null
                : (isSmallScreen
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all),
            indicatorColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.1),
            selectedIconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.primary,
            ),
            unselectedIconTheme: const IconThemeData(color: Color(0xFF484F58)),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.style_outlined),
                selectedIcon: Icon(Icons.style),
                label: Text('BEST HAND'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.compare_arrows_outlined),
                selectedIcon: Icon(Icons.compare_arrows),
                label: Text('COMPARE'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: Text('PROBABILITY'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }

  Widget _statusIndicator(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ],
    ),
  );
}
