import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bitcoin_blockchain_explorer/screens/networkstatus.dart';
import 'package:bitcoin_blockchain_explorer/screens/settings.dart';
import 'package:bitcoin_blockchain_explorer/providers/settings_provider.dart';

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
  // Is GetBlock already defined?
  final bool hasToken = prefs.containsKey('token');
  String? token;  
  if (hasToken) {
    token = prefs.getString('token');
  } else {
    token = '';
  }

  runApp(
    ProviderScope(
      child: BitcoinBlokchainExplorer(
        hasToken: hasToken,
        token: token!,
      )
    )
  );
}

class BitcoinBlokchainExplorer extends ConsumerWidget {
  const BitcoinBlokchainExplorer({
    super.key,
    required this.token,
    required this.hasToken,
  });

  final String token;
  final bool hasToken;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set token in settingsProvider
      final settingsNotifier = ref.read(settingsProvider.notifier);
      settingsNotifier.setSettings(Settings(token: token));
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
