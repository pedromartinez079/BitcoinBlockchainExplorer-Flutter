import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bitcoin_blockchain_explorer/providers/settings_provider.dart';
import 'package:bitcoin_blockchain_explorer/screens/networkstatus.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key,});

  @override
  ConsumerState<SettingsScreen> createState() {
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _tokenController = TextEditingController();
  bool _obscureApiKey = true;

  // Store GetBlock Token
  Future<void> storetoken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    
    try {
      await prefs.setString('token', token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.cyanAccent,
          content: Text('GetBlock Token saved.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.cyanAccent,
          content: Text(e.toString()),
        ),
      );
    }
  }

  // Set Token button method
  void _saveToken() async {
    final token = _tokenController.text;

    if (token.isEmpty || token == '') {
      return;
    }
    // Set Provider
    ref.read(settingsProvider.notifier).setSettings(Settings(token: token));
    // Update SharedPreferences
    storetoken(token);

    // Wait and go to Assistant screen
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const NetworkStatusScreen(),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings'),),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Set Token input
              TextField(
                controller: _tokenController,
                obscureText: _obscureApiKey,
                decoration: InputDecoration(
                  labelText: 'GetBlock token',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureApiKey
                      ? Icons.visibility
                      : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _obscureApiKey = !_obscureApiKey);
                    },
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height:40),
              // Set Token button
              ElevatedButton.icon(
                onPressed: _saveToken,
                icon: const Icon(Icons.key),
                label: const Text('Set Token'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}