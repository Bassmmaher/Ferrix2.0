sealed class AuthError implements Exception {
  final String message;
  AuthError(this.message);

  @override
  String toString() => message;
}

class ValidationError extends AuthError {
  ValidationError(super.message);
}

class EmailAlreadyExistsError extends AuthError {
  EmailAlreadyExistsError() : super('Email already registered');
}

class UserNotFoundError extends AuthError {
  UserNotFoundError() : super('User not found');
}

class InvalidCredentialsError extends AuthError {
  InvalidCredentialsError() : super('Invalid email or password');
}

class UserNotVerifiedError extends AuthError {
  UserNotVerifiedError() : super('Email not verified');
}

class OtpExpiredError extends AuthError {
  OtpExpiredError() : super('OTP expired');
}

class OtpInvalidError extends AuthError {
  OtpInvalidError() : super('Invalid OTP');
}

class OtpTooManyAttemptsError extends AuthError {
  OtpTooManyAttemptsError() : super('Too many attempts');
}

class OtpNotFoundError extends AuthError {
  OtpNotFoundError() : super('No OTP found. Request a new one.');
}