import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/database.dart';
import '../../../core/result.dart';
import '../domain/auth_repository.dart';
import '../domain/validation.dart';

class LocalAuth implements AuthRepository {
  LocalAuth(this.db, this.storage, {this.latency = const Duration(seconds: 1)});

  final DonutDatabase db;
  final FlutterSecureStorage storage;
  final Duration latency;
  static const _sessionKey = 'member_phone';

  Future<Result<T>> _run<T>(
    Future<T> Function() action, {
    bool delay = true,
  }) async {
    try {
      if (delay) await Future<void>.delayed(latency);
      return Ok(await action());
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stack),
      );
      return const Failure(
        'Could not access local account data. Please try again.',
      );
    }
  }

  Future<Account?> _account(String phone) async {
    final row = await db
        .customSelect(
          'SELECT * FROM accounts WHERE phone = ?',
          variables: [Variable(phone)],
        )
        .getSingleOrNull();
    if (row == null) return null;
    return (
      phone: phone,
      firstName: row.read<String>('first_name'),
      lastName: row.read<String>('last_name'),
      birth: DateTime.parse(row.read<String>('birth')),
    );
  }

  @override
  Future<Result<Account?>> restore() => _run(() async {
    final phone = await storage.read(key: _sessionKey);
    return phone == null ? null : _account(phone);
  }, delay: false);

  @override
  Future<Result<bool>> requestCode(String phone, {required bool register}) =>
      _run(() async => register || await _account(phone) != null);

  @override
  Future<Result<Account?>> verify(
    String phone,
    String code, {
    required bool register,
  }) {
    if (!validOtp(code)) return Future.value(const Failure('Incorrect code.'));
    return _run(() async {
      final account = await _account(phone);
      if (account != null) await storage.write(key: _sessionKey, value: phone);
      return account;
    });
  }

  @override
  Future<Result<Account>> register(Account account) => _run(() async {
    await db.customStatement(
      'INSERT OR IGNORE INTO accounts VALUES (?, ?, ?, ?)',
      [
        account.phone,
        account.firstName,
        account.lastName,
        account.birth.toIso8601String(),
      ],
    );
    final saved = (await _account(account.phone))!;
    await storage.write(key: _sessionKey, value: saved.phone);
    return saved;
  });

  @override
  Future<Result<void>> logout() =>
      _run(() => storage.delete(key: _sessionKey), delay: false);
}
