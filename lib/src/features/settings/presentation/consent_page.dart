import 'package:flutter/material.dart';

class ConsentPage extends StatelessWidget {
  const ConsentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Açık Rıza Metni')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _H('Açık Rızanın Konusu'),
          _P('Belirtilen kişisel verilerin pazarlama/analiz amaçlarıyla işlenmesine rıza verilir.'),
          _H('Rızanın Geri Alınması'),
          _P('Dilediğiniz zaman ayarlar > gizlilik bölümünden geri çekebilirsiniz.'),
          _H('Rızanın Süresi'),
          _P('Geri çekilene kadar veya amaç ortadan kalkana kadar.'),
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
