import 'package:flutter/material.dart';

class CookiesPolicyPage extends StatelessWidget {
  const CookiesPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Çerez Politikası')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _H('Çerez Nedir?'),
          _P('Çerezler, cihazınıza kaydedilen küçük metin dosyalarıdır.'),
          _H('Kullandığımız Çerez Türleri'),
          _P('Zorunlu, performans, işlevsel ve pazarlama çerezleri.'),
          _H('Yönetim'),
          _P('Tarayıcı ayarlarından çerez tercihlerinizi yönetebilirsiniz.'),
          _H('İletişim'),
          _P('cookies@uniworkly.app'),
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
