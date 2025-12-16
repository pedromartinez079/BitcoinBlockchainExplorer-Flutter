import 'package:flutter_riverpod/legacy.dart';

class Settings {
  final String token;

  const Settings({
    required this.token,
  });
}

class SettingsNotifier extends StateNotifier<Settings> {
  SettingsNotifier()
    : super(const Settings(token: '',));

  void setSettings(Settings settings) {
    state = settings;
  }

  String getToken() { return state.token; }
}

final settingsProvider =
  StateNotifierProvider<SettingsNotifier, Settings>((ref) {
    return SettingsNotifier();
  });