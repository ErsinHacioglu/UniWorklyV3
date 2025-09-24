// lib/src/features/student/student_home_page.dart
import 'package:flutter/material.dart';

// Orta buton "İlanlar" sayfası:
import '../listings/listings_page.dart';

// Sağdaki sekme "Mesajlarım" kabuğu:
import '../messages/messages_shell.dart';

// Soldaki sekme "İşlerim" sayfası (yeni):
import '../jobs/presentation/jobs_page.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  // 0: İşlerim, 1: İlanlar, 2: Mesajlarım
  int _index = 1;

  @override
  Widget build(BuildContext context) {
    final pages = [
      JobsPage(),      // <-- SOLDAN: İşlerim (yeni)
      ListingsPage(),  // <-- ORTA:  İlanlar (FAB ile açılıyor)
      MessagesShell(), // <-- SAĞ:   Mesajlarım
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('UniWorkly'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Ayarlar',
          onPressed: () => Navigator.pushNamed(context, '/settings'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Bildirimler',
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Profil',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),

      body: pages[_index],

      // ORTA BÜYÜK BUTON: İlanlar
      floatingActionButton: _ListingsFab(
        selected: _index == 1,
        onTap: () => setState(() => _index = 1),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Alt bar: solda İşlerim, sağda Mesajlarım; ortada oval kesim
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavButton(
                label: 'İşlerim',
                icon: Icons.work_outline_rounded,
                selected: _index == 0,
                onTap: () => setState(() => _index = 0),
              ),
              _NavButton(
                label: 'Mesajlarım',
                icon: Icons.chat_bubble_outline_rounded,
                selected: _index == 2,
                onTap: () => setState(() => _index = 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Orta, yuvarlak, gölgeli “İlanlar” FAB’i
class _ListingsFab extends StatelessWidget {
  const _ListingsFab({required this.onTap, required this.selected});

  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: 84,
      height: 84,
      child: Material(
        elevation: 10,
        color: selected ? cs.primary : cs.primaryContainer,
        shape: const CircleBorder(),
        shadowColor: Colors.black.withOpacity(0.25),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 28,
                  color: selected ? cs.onPrimary : cs.onPrimaryContainer,
                ),
                const SizedBox(height: 4),
                Text(
                  'İlanlar',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? cs.onPrimary : cs.onPrimaryContainer,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? cs.primary : cs.onSurfaceVariant),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: selected ? cs.primary : cs.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}