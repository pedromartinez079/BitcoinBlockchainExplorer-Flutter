import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:bitcoin_blockchain_explorer/screens/networkstatus.dart';
import 'package:bitcoin_blockchain_explorer/screens/settings.dart';
import 'package:bitcoin_blockchain_explorer/providers/settings_provider.dart';
import 'package:bitcoin_blockchain_explorer/providers/wallets_provider.dart';

// Color scheme for Theme
final colorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 230, 106, 5),
  surface: const Color.fromARGB(255, 230, 106, 5),
);
// Theme definition
final theme = ThemeData().copyWith(
  scaffoldBackgroundColor: colorScheme.surface,
  colorScheme: colorScheme,
  textTheme: GoogleFonts.ubuntuCondensedTextTheme().copyWith(
    titleSmall: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
    ),
    titleMedium: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
    ),
    titleLarge: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
    ),
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  // GetBlock or Wallets already defined?
  final bool hasToken = prefs.containsKey('token');
  final bool hasWallets = prefs.containsKey('wallets');
  String? token;
  String? jsonString;
  List<Wallet>? wallets;

  if (hasToken) {
    token = prefs.getString('token');
  } else {
    token = '';
  }

  if (hasWallets) {
    jsonString = prefs.getString('wallets');

    if (jsonString != null) {
      List<dynamic> jsonData = jsonDecode(jsonString);
      wallets = jsonData.map((item) => Wallet.fromJson(item)).toList();
    } else {
      wallets = [];
    }
  } else {
    wallets = [];
  }

  runApp(
    ProviderScope(
      child: BitcoinBlokchainExplorer(
        hasToken: hasToken,
        token: token!,
        wallets: wallets,
      )
    )
  );
}

class BitcoinBlokchainExplorer extends ConsumerWidget {
  const BitcoinBlokchainExplorer({
    super.key,
    required this.token,
    required this.hasToken,
    required this.wallets,
  });

  final String token;
  final bool hasToken;
  final List<Wallet> wallets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set token in settingsProvider
      final settingsNotifier = ref.read(settingsProvider.notifier);
      settingsNotifier.setSettings(Settings(token: token));
      // Set wallets in walletsProvider
      final walletsNotifier = ref.read(walletsProvider.notifier);      
      walletsNotifier.setWallets(Wallets(wallets: wallets));
    });

    return MaterialApp(
      title: 'Bitcoin Blockchain Explorer',
      theme: theme,
      home: hasToken
        ? NetworkStatusScreen()
        : SettingsScreen()
    );
  }
}
