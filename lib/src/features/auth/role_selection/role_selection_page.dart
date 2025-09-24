// lib/src/features/auth/role_selection/role_selection_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { ogrenci, isveren }
final userRoleProvider = StateProvider<UserRole?>((ref) => null);

class RolePrefs {
  static const _key = 'selected_role';
  static Future<void> save(UserRole role) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, role.name);
  }

  static Future<UserRole?> load() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getString(_key);
    if (v == null) return null;
    return UserRole.values.firstWhere((e) => e.name == v, orElse: () => UserRole.ogrenci);
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key);
  }
}

class RoleSelectionPage extends ConsumerWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('UniWorkly'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;

          final cards = [
            _RoleCard(
              title: 'Öğrenci',
              subtitle: 'İlanlara göz at, başvur, profili doldur',
              icon: Icons.school_outlined,
              onTap: () => _onSelect(context, ref, UserRole.ogrenci),
            ),
            _RoleCard(
              title: 'İşveren',
              subtitle: 'İlan oluştur, başvuruları yönet',
              icon: Icons.work_outline,
              onTap: () => _onSelect(context, ref, UserRole.isveren),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Başla',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Lütfen devam etmek için rolünü seç',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 28),
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
                      // “rolü sonra ayarlayacağım” kaldırıldı
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

  Future<void> _onSelect(BuildContext context, WidgetRef ref, UserRole role) async {
    ref.read(userRoleProvider.notifier).state = role;
    await RolePrefs.save(role);

    // pushNamed => geri ile RoleSelection’a dönebil
    switch (role) {
      case UserRole.ogrenci:
        if (context.mounted) Navigator.pushNamed(context, '/student');
        break;
      case UserRole.isveren:
       if (context.mounted) {
        Navigator.pushNamed(context, '/employerType'); // ÖNCE tip seçimi
      }
      break;
    }
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 6))],
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(14),
              child: Icon(icon, size: 28, color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }
}
