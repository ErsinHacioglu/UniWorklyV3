import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gizlilik Politikası')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _H('Toplanan Veriler'),
          _P('Ad, iletişim bilgileri, kullanım verileri ve cihaz bilgileri işlenebilir.'),
          _H('İşleme Amaçları'),
          _P('Hizmet sunumu, güvenlik, performans izleme ve kişiselleştirme.'),
          _H('Üçüncü Taraflarla Paylaşım'),
          _P('Yasal zorunluluklar ve hizmet sağlayıcılarla sınırlı paylaşım yapılabilir.'),
          _H('Saklama Süresi'),
          _P('Mevzuat ve meşru amaçlar doğrultusunda gerekli süre boyunca saklanır.'),
          _H('Haklarınız'),
          _P('Erişim, düzeltme, silme, itiraz ve taşınabilirlik haklarına sahipsiniz.'),
          _H('İletişim'),
          _P('Sorular için: privacy@uniworkly.app'),
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
