// lib/src/features/employer/type_selection/employer_type_selection_page.dart
import 'package:flutter/material.dart';

// RolePrefs, EmployerType (ve gerekiyorsa UserRole) buradan geliyor.
// Eğer RolePrefs'i ayrı bir dosyaya taşıdıysan, o dosyayı import et.
import '../../auth/role_selection/role_prefs.dart'; // <-- BUNU EKLE/KULLAN

class EmployerTypeSelectionPage extends StatelessWidget {
  const EmployerTypeSelectionPage({super.key});

  Future<void> _selectAndGo(
    BuildContext context, {
    required EmployerType type,
    required String route,
  }) async {
    // İşveren tipini kalıcı olarak kaydet
    await RolePrefs.saveEmployerType(type);
    if (context.mounted) {
      // İleri giderken pushNamed: geri ile bu ekrana dönebil
      Navigator.pushNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget buildCard({
      required String title,
      required String subtitle,
      required IconData icon,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(14),
                child: Icon(icon, size: 28, color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('İşveren Tipi Seç'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;
          final cards = [
            buildCard(
              title: 'Kurumsal',
              subtitle: 'Şirket olarak ilan ver',
              icon: Icons.business_center_outlined,
              onTap: () => _selectAndGo(
                context,
                type: EmployerType.kurumsal,
                route: '/employer/corporate',
              ),
            ),
            buildCard(
              title: 'Özel Ders',
              subtitle: 'Bireysel ders ilanı ver',
              icon: Icons.menu_book_outlined,
              onTap: () => _selectAndGo(
                context,
                type: EmployerType.ozelDers,
                route: '/employer/tutor',
              ),
            ),
          ];

          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [cs.primaryContainer.withOpacity(0.25), cs.surface],
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Devam etmek için tip seç',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 24),
                      if (isWide)
                        Row(
                          children: [
                            Expanded(child: cards[0]),
                            const SizedBox(width: 20),
                            Expanded(child: cards[1]),
                          ],
                        )
                      else
                        Column(
                          children: [
                            cards[0],
                            const SizedBox(height: 16),
                            cards[1],
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
