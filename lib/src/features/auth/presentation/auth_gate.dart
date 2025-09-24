// lib/src/features/auth/presentation/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'login_page.dart';
import '../application/auth_controller.dart'; // authStateChangesProvider
import '../../auth/role_selection/role_prefs.dart'; // RolePrefs + UserRole + EmployerType

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sadece "signed-out -> signed-in" geçişinde tetikle
    ref.listen<AsyncValue<String?>>(authStateChangesProvider, (prev, next) {
      final was = prev?.valueOrNull; // önceki uid
      final now = next.valueOrNull;  // şimdiki uid
      if (was == null && now != null) {
        _routeAfterSignIn(context);
      }
    });

    final auth = ref.watch(authStateChangesProvider);

    return auth.when(
      // Kullanıcı yoksa → Login
      data: (uid) {
        if (uid == null) return const LoginPage();

        // Uygulama açıkken zaten girişliyse de yönlendir (örn. hot restart)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _routeAfterSignIn(context);
        });

        // Yönlendirme olurken kısa loader
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
    );
  }

  /// Giriş yaptıktan sonra kayıtlı role/employerType'a göre rota seç
  Future<void> _routeAfterSignIn(BuildContext context) async {
    final role = await RolePrefs.load();
    if (!context.mounted) return;

    if (role == null) {
      // Rol seçilmemiş → rol seçimi
      Navigator.pushNamed(context, '/role');
      return;
    }

    if (role == UserRole.ogrenci) {
      Navigator.pushNamed(context, '/student');
      return;
    }

    // role == isveren → employer type kontrol et
    final empType = await RolePrefs.loadEmployerType();
    if (!context.mounted) return;

    if (empType == null) {
      Navigator.pushNamed(context, '/employerType'); // Kurumsal mı Özel Ders mi?
    } else if (empType == EmployerType.kurumsal) {
      Navigator.pushNamed(context, '/employer/corporate');
    } else {
      Navigator.pushNamed(context, '/employer/tutor');
    }
  }
}
