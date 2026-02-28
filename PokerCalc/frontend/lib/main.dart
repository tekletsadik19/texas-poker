import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/datasources/poker_remote_data_source.dart';
import 'data/repositories/poker_repository_impl.dart';
import 'domain/repositories/poker_repository.dart';
import 'presentation/pages/home_page.dart';

// Simple dependency injection
final PokerRepository pokerRepository = PokerRepositoryImpl(
  remoteDataSource: PokerRemoteDataSource(baseUrl: 'http://34.27.70.130'),
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
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF27AE60),
          secondary: Color(0xFFE74C3C),
          surface: Colors.white,
          outline: Color(0xFFE1E4E8),
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: false,
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE1E4E8),
          thickness: 1,
        ),
      ),
      home: const PokerHomePage(),
    );
  }
}
