import 'package:flutter/material.dart';
import 'pages/best_hand_page.dart';
import 'pages/compare_page.dart';
import 'pages/probability_page.dart';

void main() {
  runApp(const PokerCalcApp());
}

class PokerCalcApp extends StatelessWidget {
  const PokerCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokerCalc – Texas Hold\'em Analyzer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1117),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF27AE60),
          secondary: const Color(0xFFE74C3C),
          surface: const Color(0xFF141C22),
        ),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const PokerHomePage(),
    );
  }
}

class PokerHomePage extends StatefulWidget {
  const PokerHomePage({super.key});

  @override
  State<PokerHomePage> createState() => _PokerHomePageState();
}

class _PokerHomePageState extends State<PokerHomePage> {
  int _selectedIndex = 0;

  static const _pages = [BestHandPage(), ComparePage(), ProbabilityPage()];

  static const _subtitles = [
    'Evaluate your 7-card hand',
    'Head-to-head showdown',
    'Monte Carlo simulation',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF141C22),
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF27AE60).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF27AE60).withOpacity(0.4),
                ),
              ),
              child: const Text('🃏', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PokerCalc',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _subtitles[_selectedIndex],
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8FA4BB),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF27AE60).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF27AE60).withOpacity(0.3),
                ),
              ),
              child: const Text(
                'Texas Hold\'em',
                style: TextStyle(
                  color: Color(0xFF27AE60),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: const Color(0xFF0E161E),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            selectedIconTheme: const IconThemeData(color: Color(0xFF27AE60)),
            selectedLabelTextStyle: const TextStyle(
              color: Color(0xFF27AE60),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedIconTheme: const IconThemeData(color: Color(0xFF4A6274)),
            unselectedLabelTextStyle: const TextStyle(
              color: Color(0xFF4A6274),
              fontSize: 12,
            ),
            labelType: NavigationRailLabelType.all,
            leading: const SizedBox(height: 8),
            indicatorColor: const Color(0xFF27AE60).withOpacity(0.15),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.star_border),
                selectedIcon: Icon(Icons.star),
                label: Text('Best\nHand'),
                padding: EdgeInsets.symmetric(vertical: 4),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.compare_arrows),
                label: Text('Compare'),
                padding: EdgeInsets.symmetric(vertical: 4),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: Text('Odds'),
                padding: EdgeInsets.symmetric(vertical: 4),
              ),
            ],
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: Color(0xFF1C2833),
          ),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}
