import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../jobs/application/jobs_controller.dart';
import '../jobs/domain/job_models.dart';
import '../jobs/presentation/jobs_page.dart';
import '../jobs/presentation/job_detail_page.dart';
import '../messages/chat_page.dart';

/// Bildirim tipleri
enum NotificationType {
  applicationApproved,   // İlan başvurusu onaylandı
  upcomingJobReminder,   // Yaklaşan iş hatırlatma
  checkInWindowOpen,     // Check-in penceresi açıldı
  message,               // Yeni mesaj
}

/// Basit bildirim modeli
class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime time;

  /// Payload — ilgili sayfaya giderken kullanacağız
  final String? jobId;        // iş detayı için
  final String? listingId;    // (şimdilik /jobs > Başvurularım’a yönlendiriyoruz)
  final String? chatThreadId; // sohbet için
  final String? chatName;     // sohbet başlığı için

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.jobId,
    this.listingId,
    this.chatThreadId,
    this.chatName,
  });
}

/// ÖRNEK BİLDİRİMLER (mock)
final _mockNotifications = <AppNotification>[
  AppNotification(
    id: 'n1',
    type: NotificationType.applicationApproved,
    title: 'Başvurunuz kabul edildi',
    body: '“EventX Karşılama Görevlisi” ilanına başvurunuz onaylandı.',
    time: DateTime.now().subtract(const Duration(minutes: 5)),
    listingId: 'listing_eventx',
  ),
  AppNotification(
    id: 'n2',
    type: NotificationType.upcomingJobReminder,
    title: 'Yarın bir işiniz var',
    body: '“Depo Sayım – LogiCo” yarın 20:30’da başlıyor.',
    time: DateTime.now().subtract(const Duration(hours: 1)),
    jobId: 'job_depo_sayim',
  ),
  AppNotification(
    id: 'n3',
    type: NotificationType.checkInWindowOpen,
    title: 'Check-in zamanı yaklaşıyor',
    body: '“EventX Karşılama” için check-in 15 dk içinde açılacak.',
    time: DateTime.now().subtract(const Duration(hours: 3)),
    jobId: 'job_eventx',
  ),
  AppNotification(
    id: 'n4',
    type: NotificationType.message,
    title: 'Yeni mesaj',
    body: 'Cafe Nox: “Yarın 10 dk erken gelebilir misin?”',
    time: DateTime.now().subtract(const Duration(days: 1)),
    chatThreadId: 'employer_Cafe Nox',
    chatName: 'Cafe Nox',
  ),
];

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Bildirimler')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        itemCount: _mockNotifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final n = _mockNotifications[i];
          final (icon, tint) = _iconFor(n.type, cs);
          return Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: Icon(icon, color: tint),
              title: Text(n.title),
              subtitle: Text('${n.body}\n${_fmt(n.time)}'),
              isThreeLine: true,
              onTap: () => _openNotification(context, ref, n),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }

  // Bildirime göre ilgili sayfaya git
  Future<void> _openNotification(
      BuildContext context, WidgetRef ref, AppNotification n) async {
    switch (n.type) {
      case NotificationType.applicationApproved:
        // İlan özel sayfası hazır değilse: Başvurularım sekmesine götürelim
        ref.read(jobsTabProvider.notifier).state = 1; // Başvurularım
        if (context.mounted) {
          Navigator.pushNamed(context, '/jobs');
        }
        break;

      case NotificationType.upcomingJobReminder:
      case NotificationType.checkInWindowOpen:
        if (n.jobId != null) {
          final state = ref.read(jobsControllerProvider);
          final job = (state.jobs.value ?? [])
              .cast<Job?>()
              .firstWhere((j) => j?.id == n.jobId, orElse: () => null);
          if (job != null) {
            if (context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => JobDetailPage(job: job)),
              );
            }
            break;
          }
        }
        // yedek: İşlerim sayfası
        if (context.mounted) {
          ref.read(jobsTabProvider.notifier).state = 0;
          Navigator.pushNamed(context, '/jobs');
        }
        break;

      case NotificationType.message:
        if (n.chatThreadId != null && n.chatName != null) {
          if (context.mounted) {
            Navigator.pushNamed(
              context,
              '/chat',
              arguments: ChatArgs(id: n.chatThreadId!, name: n.chatName!),
            );
          }
        }
        break;
    }
  }

  // Görsel ipucu için ikon & renk
  (IconData, Color) _iconFor(NotificationType t, ColorScheme cs) {
    switch (t) {
      case NotificationType.applicationApproved:
        return (Icons.check_circle, Colors.green.shade700);
      case NotificationType.upcomingJobReminder:
        return (Icons.event_available, cs.primary);
      case NotificationType.checkInWindowOpen:
        return (Icons.login_rounded, Colors.orange.shade800);
      case NotificationType.message:
        return (Icons.chat_bubble_outline, cs.tertiary);
    }
  }

  String _fmt(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
    // İstersen intl ile locale format kullanabiliriz.
  }
}
