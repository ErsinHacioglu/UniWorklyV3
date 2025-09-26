import 'package:flutter/material.dart';

class KvkkPage extends StatelessWidget {
  const KvkkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KVKK Aydınlatma Metni')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _H('Veri Sorumlusu'),
          _P('Uniworkly yazılımı veri sorumlusudur.'),
          _H('İşleme Kapsamı'),
          _P('6698 sayılı KVKK uyarınca kişisel verileriniz meşru amaçlarla işlenmektedir.'),
          _H('Toplama Yöntemi ve Hukuki Sebep'),
          _P('Sözleşmenin ifası, açık rıza, meşru menfaat ve kanuni yükümlülükler.'),
          _H('Aktarım'),
          _P('Gerekli güvenlik önlemleri ile yurt içi/yurt dışı hizmet sağlayıcılarına aktarım yapılabilir.'),
          _H('Haklarınız (KVKK m.11)'),
          _P('Bilgi talep etme, düzeltme, silme, itiraz ve tazminat hakları. '
              'Başvurular: kvkk@uniworkly.app'),
        ],
      ),
    );
  }
}

class _H extends StatelessWidget {
  final String t;
  const _H(this.t);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      );
}

class _P extends StatelessWidget {
  final String t;
  const _P(this.t);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t),
      );
}
