import '../entities/otp.dart';
import '../enums/otp_purpose.dart';
import '../value_objects/email.dart';

abstract class OtpRepository {
  Future<void> save(Otp otp);
  Future<Otp?> find(Email email, OtpPurpose purpose);
  Future<void> delete(Email email, OtpPurpose purpose);
}