import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Text('Uniworkly',
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text('Hesabına giriş yap',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                  const SizedBox(height: 28),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'E-posta'),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'E-posta gerekli';
                            if (!v.contains('@')) return 'Geçerli bir e-posta girin';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _pass,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: 'Şifre',
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscure = !_obscure),
                              icon: Icon(_obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                            ),
                          ),
                          validator: (v) =>
                              (v == null || v.length < 6) ? 'En az 6 karakter' : null,
                        ),
                        const SizedBox(height: 20),
                        state.isLoading
                            ? const SizedBox(
                                height: 52,
                                child: Center(child: CircularProgressIndicator()))
                            : ElevatedButton(
                                onPressed: () async {
                                  if (!_formKey.currentState!.validate()) return;
                                  await ref
                                      .read(authControllerProvider.notifier)
                                      .signIn(_email.text.trim(), _pass.text);
                                },
                                child: const Text('Giriş yap'),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Şifremi unuttum'),
                  ),
                  const Spacer(),
                  Text(
                    'Devam ederek Kullanım Koşulları ve Gizlilik’i kabul etmiş olursun.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
