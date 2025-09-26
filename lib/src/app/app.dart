import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/auth_gate.dart';
import '../features/auth/role_selection/role_selection_page.dart';
import '../features/employer/employer_home_page.dart';
import 'theme.dart';
import '../features/employer/type_selection/employer_type_selection_page.dart';
import '../features/employer/tutor_home_page.dart';
import '../features/student/student_home_page.dart';
import '../features/settings/settings_page.dart';
import '../features/notifications/notifications_page.dart';
import '../features/profile/profile_page.dart';
import '../features/profile/company_profile_page.dart';
import '../features/listings/listing_detail_page.dart';
import '../features/profile/company_reviews_page.dart';
import '../features/settings/presentation/security_page.dart';
import '../features/settings/presentation/preferences_page.dart';
import '../features/settings/presentation/help_page.dart';
import '../features/settings/presentation/privacy_page.dart';
// ChatArgs + ChatPage
import '../features/messages/chat_page.dart';
// JobsPage
import '../features/jobs/presentation/jobs_page.dart';

// Tema state'i buradan geliyor
import '../features/settings/application/preferences_controller.dart';

class UniworklyApp extends ConsumerWidget {
  const UniworklyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = buildTheme();
    final themeMode = ref.watch(preferencesControllerProvider).themeMode; // Sistem / Açık / Koyu

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Uniworkly',
      theme: theme, // açık tema (beyaz)
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark, // koyu tema (siyah)
      ),
      themeMode: themeMode, // seçime göre uygula
      home: const AuthGate(), // AuthGate login durumuna göre yönlendirme yapacak
      routes: {
        '/jobs': (context) => const JobsPage(),
        '/chat': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as ChatArgs;
          return Scaffold(body: ChatPage(args: args));
        },

        SettingsPage.routeName: (_) => const SettingsPage(),
        SecurityPage.routeName: (_) => const SecurityPage(),
        PreferencesPage.routeName: (_) => const PreferencesPage(),
        HelpPage.routeName: (_) => const HelpPage(),
        PrivacyPage.routeName: (_) => const PrivacyPage(),

        '/role': (context) => const RoleSelectionPage(),
        '/student': (context) => const StudentHomePage(),
        '/employerType': (context) => const EmployerTypeSelectionPage(),
        '/employer/corporate': (context) => const EmployerHomePage(), // Kurumsal
        '/employer/tutor': (context) => const TutorHomePage(),        // Özel Ders

        '/settings': (context) => const SettingsPage(),
        '/notifications': (context) => const NotificationsPage(),
        '/profile': (context) => const ProfilePage(),

        '/companyProfile': (context) {
          final listing = ModalRoute.of(context)!.settings.arguments as dynamic;
          return CompanyProfilePage(listing: listing);
        },
        '/companyReviews': (context) {
          final listing = ModalRoute.of(context)!.settings.arguments as dynamic;
          return CompanyReviewsPage(listing: listing);
        },
      },
    );
  }
}
