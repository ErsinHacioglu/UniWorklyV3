import 'package:flutter/material.dart';
import '../../jobs/domain/job_models.dart';

class JobDetailPage extends StatelessWidget {
  final Job job;
  const JobDetailPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('İş Detayı')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(job.companyName, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text('${fmt(job.startAt)}  •  ${fmt(job.endAt)}'),
            const SizedBox(height: 12),
            Text('Durum: ${job.status.name}  '
                '${job.status == JobStatus.past ? '(${job.outcome == JobOutcome.failed ? 'tamamlanamadı' : 'tamamlandı'})' : ''}'),
          ],
        ),
      ),
    );
  }
}
