import 'dart:math';
import 'package:flutter/material.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});
  static const routeName = '/settings/security';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Güvenlik')),
      body: ListView(
        children: [
          // ŞİFRE
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text('Şifre'),
            subtitle: const Text('Şifreyi değiştir'),
            onTap: () => _openPasswordSheet(context),
          ),
          // E-POSTA (AYRI)
          ListTile(
            leading: const Icon(Icons.alternate_email),
            title: const Text('E-posta'),
            subtitle: const Text('E-postayı güncelle ve doğrula'),
            onTap: () => _openEmailSheet(context),
          ),
          // TELEFON (AYRI)
          ListTile(
            leading: const Icon(Icons.phone_iphone),
            title: const Text('Telefon'),
            subtitle: const Text('Telefonu güncelle ve doğrula'),
            onTap: () => _openPhoneSheet(context),
          ),
          const Divider(),
          // HESABIMI SİL
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: FilledButton.tonal(
              onPressed: () => _deleteAccountFlow(context),
              child: const Text('HESABIMI SİL'),
            ),
          ),
        ],
      ),
    );
  }
}

/// ======================= ŞİFRE BOTTOM SHEET =======================
void _openPasswordSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => const _PasswordSheet(),
  );
}

class _PasswordSheet extends StatefulWidget {
  const _PasswordSheet();

  @override
  State<_PasswordSheet> createState() => _PasswordSheetState();
}

class _PasswordSheetState extends State<_PasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottom + 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Şifreyi Değiştir',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _old,
              decoration: const InputDecoration(labelText: 'Mevcut şifre'),
              obscureText: true,
              validator: (v) => (v == null || v.length < 4) ? 'Zorunlu' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _new,
              decoration: const InputDecoration(labelText: 'Yeni şifre'),
              obscureText: true,
              validator: (v) => (v == null || v.length < 6) ? 'En az 6 karakter' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _confirm,
              decoration: const InputDecoration(labelText: 'Yeni şifre (tekrar)'),
              obscureText: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Zorunlu';
                if (v != _new.text) return 'Şifreler eşleşmiyor';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    // TODO: backend: changePassword(_old.text, _new.text)
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Şifre güncellendi.')),
                    );
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// =================== E-POSTA SHEET (AYRI DOĞRULAMA) ==================
void _openEmailSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => const _EmailSheet(),
  );
}

class _EmailSheet extends StatefulWidget {
  const _EmailSheet();

  @override
  State<_EmailSheet> createState() => _EmailSheetState();
}

class _EmailSheetState extends State<_EmailSheet> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _code = TextEditingController();

  String? _sentCode;
  bool _verified = false;

  String _genCode() => (100000 + Random().nextInt(900000)).toString();

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    _sentCode = _genCode();
    _verified = false;
    setState(() {});
    // TODO: backend: sendEmailOtp(_email.text, code: _sentCode!)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('E-posta kodu gönderildi: $_sentCode')),
    );
  }

  void _verify() {
    if (_code.text == _sentCode) {
      setState(() => _verified = true);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('E-posta doğrulandı ✅')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Kod hatalı ❌')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottom + 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('E-posta Güncelle',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Yeni e-posta'),
              validator: (v) =>
                  (v == null || !v.contains('@')) ? 'Geçerli e-posta girin' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(onPressed: _sendCode, child: const Text('Kod gönder')),
                const Spacer(),
                if (_sentCode != null)
                  TextButton(onPressed: _verify, child: const Text('Doğrula')),
              ],
            ),
            if (_sentCode != null) ...[
              TextFormField(
                controller: _code,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'E-posta doğrulama kodu'),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    if (!_verified) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Önce e-postayı doğrulayın')),
                      );
                      return;
                    }
                    // TODO: backend: updateEmail(_email.text)
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('E-posta güncellendi.')),
                    );
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// =================== TELEFON SHEET (AYRI DOĞRULAMA) =================
void _openPhoneSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => const _PhoneSheet(),
  );
}

class _PhoneSheet extends StatefulWidget {
  const _PhoneSheet();

  @override
  State<_PhoneSheet> createState() => _PhoneSheetState();
}

class _PhoneSheetState extends State<_PhoneSheet> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _code = TextEditingController();

  String? _sentCode;
  bool _verified = false;

  String _genCode() => (100000 + Random().nextInt(900000)).toString();

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    _sentCode = _genCode();
    _verified = false;
    setState(() {});
    // TODO: backend: sendSmsOtp(_phone.text, code: _sentCode!)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('SMS kodu gönderildi: $_sentCode')),
    );
  }

  void _verify() {
    if (_code.text == _sentCode) {
      setState(() => _verified = true);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Telefon doğrulandı ✅')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Kod hatalı ❌')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottom + 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Telefon Güncelle',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Yeni telefon'),
              validator: (v) =>
                  (v == null || v.length < 10) ? 'Geçerli telefon' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(onPressed: _sendCode, child: const Text('Kod gönder')),
                const Spacer(),
                if (_sentCode != null)
                  TextButton(onPressed: _verify, child: const Text('Doğrula')),
              ],
            ),
            if (_sentCode != null) ...[
              TextFormField(
                controller: _code,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'SMS doğrulama kodu'),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    if (!_verified) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Önce telefonu doğrulayın')),
                      );
                      return;
                    }
                    // TODO: backend: updatePhone(_phone.text)
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Telefon güncellendi.')),
                    );
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ============== HESAP SİLME (mail gönder + emin misiniz?) ==============
Future<void> _deleteAccountFlow(BuildContext context) async {
  final sendMail = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Silme Talebi'),
          content: const Text(
            'Hesap silme talebinizi e-posta ile onaya göndereceğiz. Devam edilsin mi?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Gönder')),
          ],
        ),
      ) ??
      false;

  if (!sendMail) return;

  // TODO: backend: sendDeletionMail();
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Silme onayı için e-posta gönderildi.')),
  );

  final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Emin misiniz?'),
          content: const Text(
            'E-postadaki onayı tamamladıktan sonra hesabınız 30 gün içinde kalıcı olarak silinecek.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Evet, sil')),
          ],
        ),
      ) ??
      false;

  if (confirm && context.mounted) {
    // TODO: backend: requestFinalDeletion();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Silme talebi alındı. Lütfen e-postayı kontrol edin.')),
    );
  }
}
