import 'package:flutter/material.dart';

class SupportRequestsPage extends StatelessWidget {
  const SupportRequestsPage({super.key});
  static const routeName = '/settings/support-requests';

  @override
  Widget build(BuildContext context) {
    final items = _mockSupportRequests;
    return Scaffold(
      appBar: AppBar(title: const Text('Destek Taleplerim')),
      body: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (ctx, i) {
          final r = items[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: ExpansionTile(
              leading: _StatusDot(completed: r.completed),
              title: Text('#${r.id} • ${r.title}'),
              subtitle: Text(
                '${_formatDateTime(r.date)} • ${r.completed ? 'Tamamlandı' : 'Açık'}',
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                _kv('Talep id', r.id),
                _kv('Tarih-saat', _formatDateTime(r.date)),
                _kv('Durum', r.completed ? 'Tamamlandı' : 'Açık'),
                if (r.relatedEmployer != null) _kv('İşveren', r.relatedEmployer!),
                _kv('Açıklama', r.description),
                _kv('Sonuç', r.result ?? '-'),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 130, child: Text(k, style: const TextStyle(fontWeight: FontWeight.w600))),
            const SizedBox(width: 8),
            Expanded(child: Text(v)),
          ],
        ),
      );

  static String _two(int n) => n.toString().padLeft(2, '0');
  static String _formatDateTime(DateTime d) =>
      '${_two(d.day)}/${_two(d.month)}/${d.year} ${_two(d.hour)}:${_two(d.minute)}';
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.completed});
  final bool completed;
  @override
  Widget build(BuildContext context) {
    return Icon(
      completed ? Icons.check_circle : Icons.radio_button_unchecked,
      color: completed ? Colors.green : Colors.orange,
    );
    }
}

/// ——— Mock veri/model ———
class SupportRequest {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final bool completed;
  final String? result;
  final String? relatedEmployer;

  const SupportRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.completed,
    this.result,
    this.relatedEmployer,
  });
}

final _mockSupportRequests = <SupportRequest>[
  SupportRequest(
    id: '240921-001',
    title: 'Yanlış bildirim',
    description: 'Yaklaşan iş bildirimi yanlış tarihte geldi.',
    date: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
    completed: true,
    result: 'Bildirim planlayıcı düzeltildi.',
  ),
  SupportRequest(
    id: '240922-014',
    title: 'Başvuru görünmüyor',
    description: 'İlana başvurdum fakat başvurularımda görünmüyor.',
    date: DateTime.now().subtract(const Duration(days: 1, hours: 10)),
    completed: false,
    relatedEmployer: 'Acme Ltd.',
  ),
];
