import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/datasources/poker_remote_data_source.dart';
import 'data/repositories/poker_repository_impl.dart';
import 'domain/repositories/poker_repository.dart';
import 'presentation/pages/home_page.dart';

// Simple dependency injection
final PokerRepository pokerRepository = PokerRepositoryImpl(
  remoteDataSource: PokerRemoteDataSource(baseUrl: 'http://localhost:8081'),
);

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
        scaffoldBackgroundColor: const Color(0xFF0A2A12), // Deep green felt
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF27AE60),
          secondary: const Color(0xFFE74C3C),
          surface: const Color(0xFF0E2214), // Darker green surface
          outline: const Color(0xFF1E3A25),
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161B22),
          elevation: 0,
          centerTitle: false,
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF30363D),
          thickness: 1,
        ),
      ),
      home: const PokerHomePage(),
    );
  }
}
