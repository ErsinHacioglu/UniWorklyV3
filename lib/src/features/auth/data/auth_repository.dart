import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AuthRepository {
  Stream<String?> authStateChanges(); // uid veya null
  Future<void> signInWithEmail(String email, String password);
  Future<void> signOut();
}

class FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<String?>.broadcast();
  String? _uid;

  FakeAuthRepository() {
    Future.microtask(() => _controller.add(null));
  }

  @override
  Stream<String?> authStateChanges() => _controller.stream;

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _uid = 'demo-uid';
    _controller.add(_uid);
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _uid = null;
    _controller.add(null);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FakeAuthRepository();
});
