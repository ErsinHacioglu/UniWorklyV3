import 'package:flutter/material.dart';

class SupportFormPage extends StatefulWidget {
  const SupportFormPage({super.key});

  @override
  State<SupportFormPage> createState() => _SupportFormPageState();
}

class _SupportFormPageState extends State<SupportFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _employer = TextEditingController();

  String _category = 'Genel';
  final _cats = const ['Genel', 'Bildirim', 'Başvuru', 'Hesap', 'Diğer'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Talep Formu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(
                  labelText: 'Konu',
                  prefixIcon: Icon(Icons.subject),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Zorunlu' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                items: _cats
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _employer,
                decoration: const InputDecoration(
                  labelText: 'İşveren (opsiyonel)',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _desc,
                minLines: 5,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (v) => (v == null || v.trim().length < 10)
                    ? 'Lütfen durumu en az 10 karakterle açıklayın'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // TODO: ekran görüntüsü/dosya ekleme akışı (image/file picker)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dosya ekleme (yakında)')),
                      );
                    },
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Dosya Ekle'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.send),
                    label: const Text('Gönder'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // TODO: backend bağlanınca burada talep oluşturma endpoint'i çağrılır.
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Talep alındı'),
        content: const Text(
          'Talebiniz başarıyla oluşturuldu. Kayıtlarım > Destek Taleplerim bölümünden takibini yapabilirsiniz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tamam'),
          ),
        ],
      ),
    ).then((_) {
      Navigator.pop(context); // form sayfasından geri dön
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Talep gönderildi')),
      );
    });
  }
}
