// lib/src/features/applications/presentation/application_detail_page.dart
import 'package:flutter/material.dart';
import '../../applications/domain/application_models.dart';
import '../../listings/listing_detail_page.dart'; // 👈 ilan detay sayfası

class ApplicationDetailPage extends StatelessWidget {
  final Application application;
  const ApplicationDetailPage({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Başvuru Detayı')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(application.listingTitle,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(application.companyName,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                _AppStatusBadge(status: application.status),
                const SizedBox(width: 12),
                Text('Başvuru: ${fmt(application.appliedAt)}'),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'İlan Hakkında',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'İlan detayları burada gösterilecek. İstersen ilan detay sayfasına geçebilirsin.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ListingDetailPage(listingId: application.listingId),
                    ),
                  );
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('İlanı Görüntüle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppStatusBadge extends StatelessWidget {
  final ApplicationStatus status;
  const _AppStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final IconData icon;
    late final String text;

    switch (status) {
      case ApplicationStatus.pending:
        bg = Colors.amber.withOpacity(.12);
        fg = Colors.amber.shade800;
        icon = Icons.schedule;
        text = 'Onay bekliyor';
        break;
      case ApplicationStatus.approved:
        bg = Colors.green.withOpacity(.12);
        fg = Colors.green.shade700;
        icon = Icons.check;
        text = 'Onaylandı';
        break;
      case ApplicationStatus.rejected:
        bg = Colors.red.withOpacity(.12);
        fg = Colors.red.shade700;
        icon = Icons.close;
        text = 'Reddedildi';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: fg),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: fg)),
      ]),
    );
  }
}
