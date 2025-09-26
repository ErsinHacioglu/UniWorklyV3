import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/jobs_controller.dart';
import '../domain/job_models.dart';

// Chat için
import '../../messages/chat_page.dart';

class JobDetailPage extends ConsumerWidget {
  const JobDetailPage({super.key, required this.job});
  final Job job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(jobsControllerProvider);
    final ctrl  = ref.read(jobsControllerProvider.notifier);

    final progress  = state.progressByJobId[job.id];
    final checkedIn = progress?.isCheckedIn ?? false;
    final completed = progress?.isCompleted ?? false;

    // 🔒 İletişim kilidi – işten 24 saat önce aktif (ŞİMDİLİK DEVRE DIŞI)
    // final bool canContact = DateTime.now().isAfter(job.startAt.subtract(const Duration(hours: 24)));
    final bool canContact = true; // <-- deneme için açık

    return Scaffold(
      appBar: AppBar(
        title: Text(job.title)

      ),

      // Alt sabit bar
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 10)],
          ),
          child: Row(
            children: [
              // Sorun Bildir — sadece check-in yapıldıysa ve tamamlanmadıysa
              if (checkedIn && !completed)
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.report_problem_outlined),
                    label: const Text('Sorun Bildir'),
                    onPressed: () async {
                      final txt = await _showIssueDialog(context);
                      if (txt == null || txt.trim().isEmpty) return;
                      // TODO: ctrl.reportIssue(job.id, txt) gibi kaydetme eklenebilir
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sorun gönderildi')),
                        );
                      }
                    },
                  ),
                ),
              if (checkedIn && !completed) const SizedBox(width: 12),

              // Check-in / Check-out
              Expanded(
                child: FilledButton.icon(
                  icon: Icon(checkedIn ? Icons.logout_rounded : Icons.login_rounded),
                  label: Text(checkedIn ? 'Check-out' : 'Check-in'),
                  style: FilledButton.styleFrom(
                    backgroundColor: checkedIn ? Colors.red : Colors.green,
                  ),
                  onPressed: () async {
                    try {
                      final code = await _showCodeDialog(
                        context,
                        title: checkedIn ? 'Check-out kodu' : 'Check-in kodu',
                      );
                      if (code == null) return;

                      if (checkedIn) {
                        await ctrl.checkOut(job, code: code);
                        if (context.mounted) {
                          await showDialog(
                            context: context,
                            builder: (_) => const _InfoDialog(
                              title: 'Başarılı',
                              message: 'Check-out başarıyla tamamlandı.',
                            ),
                          );
                        }
                      } else {
                        // 15 dk kuralı controller’da yorum satırına alındı (şimdilik serbest)
                        await ctrl.checkIn(job, code: code);
                        if (context.mounted) {
                          await showDialog(
                            context: context,
                            builder: (_) => const _InfoDialog(
                              title: 'Başarılı',
                              message: 'Check-in başarıyla tamamlandı.',
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (!context.mounted) return;
                      await showDialog(
                        context: context,
                        builder: (_) => _InfoDialog(title: 'Hata', message: e.toString()),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst bilgi satırı: İşveren adı + sağda mesaj/ara (AppBar’da da var; istersen burayı silebilirsin)
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.companyName,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Sağda yapışık küçük ikonlar (gövde içinde de dursun istiyorsan)
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Mesaj',
                      icon: const Icon(Icons.message_rounded, size: 22),
                      onPressed: canContact
                          ? () {
                              Navigator.pushNamed(
                                context,
                                '/chat',
                                arguments: ChatArgs(
                                  id: 'employer_${job.companyName}',
                                  name: job.companyName,
                                ),
                              );
                            }
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Mesajlaşma, iş başlamadan 24 saat önce aktif olur.')),
                              );
                            },
                    ),
                    IconButton(
                      tooltip: 'Ara',
                      icon: const Icon(Icons.call_rounded, size: 22),
                      onPressed: canContact
                          ? () async {
                              await showDialog(
                                context: context,
                                builder: (_) => const _InfoDialog(
                                  title: 'Arama',
                                  message: 'Arama başlat (placeholder)',
                                ),
                              );
                            }
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Arama, iş başlamadan 24 saat önce aktif olur.')),
                              );
                            },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_timeRangeText(job), style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),

            // basit ilerleme (placeholder)
            LinearProgressIndicator(
              value: _progressValue(job),
              minHeight: 14,
              borderRadius: BorderRadius.circular(999),
            ),
            const SizedBox(height: 20),

            _kv('Check-in zamanı', progress?.checkInAt != null ? _fmt(progress!.checkInAt!) : '—'),
            _kv('Check-out zamanı', progress?.checkOutAt != null ? _fmt(progress!.checkOutAt!) : '—'),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  String _timeRangeText(Job j) {
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '${fmt(j.startAt)} - ${fmt(j.endAt)}';
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  double _progressValue(Job j) {
    final now = DateTime.now();
    if (now.isBefore(j.startAt)) return 0;
    if (now.isAfter(j.endAt)) return 1;
    final total = j.endAt.difference(j.startAt).inSeconds;
    final done  = now.difference(j.startAt).inSeconds;
    if (total <= 0) return 0;
    return (done / total).clamp(0, 1).toDouble();
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(child: Text(k)),
            Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

/// Basit bilgi dialog’u
class _InfoDialog extends StatelessWidget {
  const _InfoDialog({required this.title, required this.message});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Kapat')),
        ],
      );
}

/// Kod girme dialog’u
Future<String?> _showCodeDialog(BuildContext context, {required String title}) async {
  final c = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: c,
        decoration: const InputDecoration(hintText: 'Örn: 1234'),
        keyboardType: TextInputType.number,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(context, c.text.trim()), child: const Text('Onayla')),
      ],
    ),
  );
}

/// Sorun bildirimi dialog’u
Future<String?> _showIssueDialog(BuildContext context) async {
  final c = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Sorun Bildir'),
      content: TextField(
        controller: c,
        maxLines: 5,
        decoration: const InputDecoration(hintText: 'Sorunu kısaca açıklayın'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
        FilledButton(onPressed: () => Navigator.pop(context, c.text.trim()), child: const Text('Gönder')),
      ],
    ),
  );
}
