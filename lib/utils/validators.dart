/// Static functions to validate some specific string patterns.
class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
  static final RegExp _passwordRegExp = RegExp(
    // r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]$',
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );

  /// Checks if an email is valid.
  static bool isValidEmail(String email) {
    return _emailRegExp.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    // return _passwordRegExp.hasMatch(password);
    return true;
  }
  static bool isValidFirstName(String firstName) {
    return firstName.trim().isNotEmpty;
  }
  static bool isValidLastName(String lastName) {
    return lastName.trim().isNotEmpty;
  }
  static bool isValidDisplayName(String displayName) {
    return displayName.trim().isNotEmpty;
  }
}
