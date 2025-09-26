import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/preferences_controller.dart';

class PreferencesPage extends ConsumerWidget {
  const PreferencesPage({super.key});
  static const routeName = '/settings/preferences';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesControllerProvider);
    final ctrl = ref.read(preferencesControllerProvider.notifier);

    String themeLabel(ThemeMode m) {
      switch (m) {
        case ThemeMode.light:
          return 'Açık (beyaz)';
        case ThemeMode.dark:
          return 'Koyu (siyah)';
        case ThemeMode.system:
        default:
          return 'Sistem';
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tercihler')),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Bildirimler'),
            value: prefs.notifications,
            onChanged: (v) {
              ctrl.setNotifications(v);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(v ? 'Bildirimler açıldı' : 'Bildirimler kapatıldı')),
              );
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up),
            title: const Text('Sesler'),
            value: prefs.sounds,
            onChanged: (v) {
              ctrl.setSounds(v);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(v ? 'Sesler açıldı' : 'Sesler kapatıldı')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Tema'),
            subtitle: Text(themeLabel(prefs.themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final picked = await showModalBottomSheet<ThemeMode>(
                context: context,
                showDragHandle: true,
                builder: (ctx) => _ThemePicker(current: prefs.themeMode),
              );
              if (picked != null) {
                ctrl.setThemeMode(picked);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker({required this.current});
  final ThemeMode current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<ThemeMode>(
            value: ThemeMode.system,
            groupValue: current,
            title: const Text('Sistem'),
            onChanged: (v) => Navigator.pop(context, v),
            secondary: current == ThemeMode.system ? const Icon(Icons.check) : null,
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.light,
            groupValue: current,
            title: const Text('Açık (beyaz)'),
            onChanged: (v) => Navigator.pop(context, v),
            secondary: current == ThemeMode.light ? const Icon(Icons.check) : null,
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: current,
            title: const Text('Koyu (siyah)'),
            onChanged: (v) => Navigator.pop(context, v),
            secondary: current == ThemeMode.dark ? const Icon(Icons.check) : null,
          ),
        ],
      ),
    );
  }
}
