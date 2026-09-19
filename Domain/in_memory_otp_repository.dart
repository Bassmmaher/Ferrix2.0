import '../../domain/entities/otp.dart';
import '../../domain/enums/otp_purpose.dart';
import '../../domain/repositories/otp_repository.dart';
import '../../domain/value_objects/email.dart';

class InMemoryOtpRepository implements OtpRepository {
  final Map<String, Otp> _store = {};

  String _key(Email e, OtpPurpose p) => '${e.value}::${p.name}';

  @override
  Future<void> save(Otp otp) async {
    _store[_key(otp.email, otp.purpose)] = otp;
  }

  @override
  Future<Otp?> find(Email email, OtpPurpose purpose) async =>
      _store[_key(email, purpose)];

  @override
  Future<void> delete(Email email, OtpPurpose purpose) async {
    _store.remove(_key(email, purpose));
  }
}