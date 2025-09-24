import 'package:flutter/material.dart';
import '../features/auth/presentation/auth_gate.dart';
import '../features/auth/role_selection/role_selection_page.dart';
import '../features/employer/employer_home_page.dart';
import 'theme.dart';
import '../features/employer/type_selection/employer_type_selection_page.dart';
import '../features/employer/employer_home_page.dart';     // kurumsal placeholder
import '../features/employer/tutor_home_page.dart';        // özel ders placeholder
import '../features/student/student_home_page.dart';
import '../features/settings/settings_page.dart';
import '../features/notifications/notifications_page.dart';
import '../features/profile/profile_page.dart';
import '../features/profile/company_profile_page.dart';
import '../features/listings/listing_detail_page.dart';
import '../features/profile/company_reviews_page.dart';

// YENİ: JobsPage importu
import '../features/jobs/presentation/jobs_page.dart';

class UniworklyApp extends StatelessWidget {
  const UniworklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = buildTheme();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Uniworkly',
      theme: theme,
      // AuthGate login durumuna göre yönlendirme yapacak
      home: const AuthGate(),
      routes: {
        // BURADA const kaldırıldı
        '/jobs': (context) => JobsPage(),

        '/role': (context) => const RoleSelectionPage(),
        '/student': (context) => const StudentHomePage(),
        '/employerType': (context) => const EmployerTypeSelectionPage(), // YENİ
        '/employer/corporate': (context) => const EmployerHomePage(),    // Kurumsal
        '/employer/tutor': (context) => const TutorHomePage(),           // Özel Ders
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
