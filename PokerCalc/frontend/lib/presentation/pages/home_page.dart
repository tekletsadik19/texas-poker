import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../widgets/background_pattern.dart';
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
            const SizedBox(width: 16),
            const Text(
              'PokerCalc',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.black,
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
      body: Stack(
        children: [
          const Positioned.fill(child: BackgroundPattern()),
          Row(
            children: [
              Container(
                width: 90, // Fixed sleek width
                margin: const EdgeInsets.only(right: 1), // Space for elevation
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
                child: NavigationRail(
                  backgroundColor: Colors.transparent,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (i) =>
                      setState(() => _selectedIndex = i),
                  labelType: NavigationRailLabelType.all,
                  groupAlignment: -1.0, // Start from top
                  indicatorColor:
                      Colors.transparent, // Clean look, no background blob
                  selectedIconTheme: IconThemeData(
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  unselectedIconTheme: const IconThemeData(
                    color: Color(0xFFB0B4B8),
                    size: 24,
                  ),
                  selectedLabelTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    letterSpacing: 1.0,
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    color: Color(0xFFB0B4B8),
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                    letterSpacing: 1.0,
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Icon(FluentIcons.card_ui_24_regular),
                      ),
                      selectedIcon: Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Icon(FluentIcons.card_ui_24_filled),
                      ),
                      label: Text('BEST HAND'),
                    ),
                    NavigationRailDestination(
                      icon: Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Icon(FluentIcons.arrow_sync_24_regular),
                      ),
                      selectedIcon: Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Icon(FluentIcons.arrow_sync_24_filled),
                      ),
                      label: Text('COMPARE'),
                    ),
                    NavigationRailDestination(
                      icon: Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Icon(FluentIcons.chart_person_24_regular),
                      ),
                      selectedIcon: Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Icon(FluentIcons.chart_person_24_filled),
                      ),
                      label: Text('PROBABILITY'),
                    ),
                  ],
                ),
              ),
              Expanded(child: _pages[_selectedIndex]),
            ],
          ),
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
