import 'package:flutter/material.dart';
import 'support_requests_page.dart';
import 'faq_page.dart';
import 'support_form_page.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});
  static const routeName = '/settings/help';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yardım')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.question_answer),
            title: const Text('SSS'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FaqPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('Destek Taleplerim'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SupportRequestsPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.assignment_outlined),
            title: const Text('Talep Formu'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SupportFormPage()),
            ),
          ),
        ],
      ),
    );
  }
}
