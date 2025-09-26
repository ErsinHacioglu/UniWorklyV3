import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kullanım Koşulları')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _H('1. Amaç ve Kapsam'),
          _P('Bu metin Uniworkly hizmetlerinin kullanımına ilişkin şartları belirler. '
              'Uygulamayı kullanarak bu koşulları kabul etmiş olursunuz.'),
          _H('2. Hesap ve Sorumluluk'),
          _P('Hesap bilgilerinin gizliliğinden kullanıcı sorumludur. Hizmetlerin kötüye '
              'kullanımı halinde hesap askıya alınabilir veya sonlandırılabilir.'),
          _H('3. İçerik ve Fikri Haklar'),
          _P('Platformda yer alan tüm içerik ve işaretler ilgili hak sahiplerine aittir; '
              'izinsiz kopyalanamaz, dağıtılamaz.'),
          _H('4. Hizmet Değişiklikleri'),
          _P('Uygulama; özellikleri, ücretlendirme ve erişim kurallarını değiştirme hakkını saklı tutar.'),
          _H('5. Yürürlük'),
          _P('Koşullar yayımlandığı tarihte yürürlüğe girer.'),
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
