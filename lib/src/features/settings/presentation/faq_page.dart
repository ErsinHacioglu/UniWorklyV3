import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = _faqItems;
    return Scaffold(
      appBar: AppBar(title: const Text('Sık Sorulan Sorular')),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) {
          final q = items[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: ExpansionTile(
              title: Text(q.question),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [Text(q.answer)],
            ),
          );
        },
      ),
    );
  }
}

class FaqItem {
  final String question;
  final String answer;
  const FaqItem(this.question, this.answer);
}

const _faqItems = <FaqItem>[
  FaqItem(
    'Başvurularımı nereden görebilirim?',
    'Profil > Başvurularım bölümünden tüm başvurularınızı görüntüleyebilirsiniz.',
  ),
  FaqItem(
    'Bildirimleri nasıl kapatırım?',
    'Ayarlar > Tercihler sayfasından bildirim anahtarını kapatabilirsiniz.',
  ),
  FaqItem(
    'Şifremi unuttum, ne yapmalıyım?',
    'Giriş ekranındaki “Şifremi Unuttum” akışını kullanın. E-postanıza doğrulama gönderilir.',
  ),
  FaqItem(
    'Hesabımı nasıl silebilirim?',
    'Ayarlar > Güvenlik > “Hesabımı Sil” akışını takip edin.',
  ),
];
