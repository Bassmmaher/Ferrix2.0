final _emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');

bool isValidEmail(String email) => _emailRegex.hasMatch(email);

String? validatePassword(String password) {
  if (password.length < 8) return 'Password must be at least 8 characters';
  if (!password.contains(RegExp(r'[A-Z]'))) return 'Must contain uppercase';
  if (!password.contains(RegExp(r'[a-z]'))) return 'Must contain lowercase';
  if (!password.contains(RegExp(r'[0-9]'))) return 'Must contain a digit';
  return null;
}
