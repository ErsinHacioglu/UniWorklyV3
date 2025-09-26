import 'package:flutter/material.dart';
import 'terms_page.dart';
import 'privacy_policy_page.dart';
import 'kvkk_page.dart';
import 'consent_page.dart';
import 'cookies_policy_page.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});
  static const routeName = '/settings/privacy';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gizlilik')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('Kullanım Koşulları'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Gizlilik Politikası'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: const Text('KVKK Aydınlatma Metni'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KvkkPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.how_to_reg_outlined),
            title: const Text('Açık Rıza Metni'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ConsentPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.cookie_outlined),
            title: const Text('Çerez Politikası'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CookiesPolicyPage()),
            ),
          ),
        ],
      ),
    );
  }
}
