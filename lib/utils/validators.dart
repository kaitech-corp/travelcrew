/// Static functions to validate some specific string patterns.

  RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
  RegExp _passwordRegExp = RegExp(
    // r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]$',
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );

  bool isValidEmail(String email) {
    return _emailRegExp.hasMatch(email);
  }

  bool isValidPassword(String password) {
    // return _passwordRegExp.hasMatch(password);
    return true;
  }
  bool isValidFirstName(String firstName) {
    return firstName.trim().isNotEmpty;
  }
  bool isValidLastName(String lastName) {
    return lastName.trim().isNotEmpty;
  }
  bool isValidDisplayName(String displayName) {
    return displayName.trim().isNotEmpty;
  }


