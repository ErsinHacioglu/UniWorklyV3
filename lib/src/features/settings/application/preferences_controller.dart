import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreferencesState {
  final bool notifications;
  final bool sounds;
  final ThemeMode themeMode;
  const PreferencesState({
    required this.notifications,
    required this.sounds,
    required this.themeMode,
  });

  PreferencesState copyWith({bool? notifications, bool? sounds, ThemeMode? themeMode}) {
    return PreferencesState(
      notifications: notifications ?? this.notifications,
      sounds: sounds ?? this.sounds,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class PreferencesController extends StateNotifier<PreferencesState> {
  PreferencesController()
      : super(const PreferencesState(
          notifications: true,
          sounds: true,
          themeMode: ThemeMode.system,
        ));

  void setNotifications(bool v) => state = state.copyWith(notifications: v);
  void setSounds(bool v) => state = state.copyWith(sounds: v);
  void setThemeMode(ThemeMode m) => state = state.copyWith(themeMode: m);
}

final preferencesControllerProvider =
    StateNotifierProvider<PreferencesController, PreferencesState>(
  (ref) => PreferencesController(),
);
