import '../../../core/result.dart';

typedef Account = ({
  String phone,
  String firstName,
  String lastName,
  DateTime birth,
});

abstract interface class AuthRepository {
  Future<Result<Account?>> restore();
  Future<Result<bool>> requestCode(String phone, {required bool register});
  Future<Result<Account?>> verify(
    String phone,
    String code, {
    required bool register,
  });
  Future<Result<Account>> register(Account account);
  Future<Result<void>> logout();
}
