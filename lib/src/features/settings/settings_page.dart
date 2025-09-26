import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Auth controller (signOut için)
import '../auth/application/auth_controller.dart';

// Alt sayfalar
import 'presentation/security_page.dart';
import 'presentation/preferences_page.dart';
import 'presentation/help_page.dart';
import 'presentation/privacy_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          _SettingsTile(
            icon: Icons.security,
            title: 'Güvenlik',
            subtitle: 'Şifre, e-posta/telefon, hesap sil',
            onTap: () => Navigator.pushNamed(context, SecurityPage.routeName),
          ),
          _SettingsTile(
            icon: Icons.tune,
            title: 'Tercihler',
            subtitle: 'Bildirimler, sesler, tema',
            onTap: () => Navigator.pushNamed(context, PreferencesPage.routeName),
          ),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Yardım',
            subtitle: 'SSS, destek taleplerim, talep formu',
            onTap: () => Navigator.pushNamed(context, HelpPage.routeName),
          ),
          _SettingsTile(
            icon: Icons.privacy_tip,
            title: 'Gizlilik',
            subtitle: 'Kullanım Koşulları, KVKK, Çerez vb.',
            onTap: () => Navigator.pushNamed(context, PrivacyPage.routeName),
          ),
          const Divider(),
          // ÇIKIŞ
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Çıkış yap'),
            trailing: isBusy
                ? const SizedBox(
                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : null,
            onTap: () async {
              final ok = await _confirm(context, 'Çıkış yapılsın mı?');
              if (!ok || isBusy) return;

              try {
                // 1) AuthController üzerinden gerçekten çıkış yap
                await ref.read(authControllerProvider.notifier).signOut();

                // 2) Tüm stack’i temizleyip köke dön
                if (!context.mounted) return;
                Navigator.of(context, rootNavigator: true)
                    .pushNamedAndRemoveUntil('/', (route) => false);
                // Not: Root'ta AuthGate varsa, authState null olduğunda zaten LoginPage'i gösterecek.
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Çıkış yapılamadı: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

Future<bool> _confirm(BuildContext context, String message) async {
  return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Onay'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Evet'),
            ),
          ],
        ),
      ) ??
      false;
}
