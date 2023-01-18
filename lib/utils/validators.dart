import 'dart:io';

/// Static functions to validate some specific string patterns.

RegExp _emailRegExp = RegExp(
  // r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
);
RegExp _passwordRegExp = RegExp(
  r'^(?=[^\d_])\w(\w|[!@#$%]){7,20}',
);

bool isValidEmail(String email) {
  return _emailRegExp.hasMatch(email);
  // return email.length ==4;
}

bool isValidPassword(String password) {
  return _passwordRegExp.hasMatch(password);
  // return true;
}

bool isValidFirstName(String? firstName) {
  return firstName?.trim().isNotEmpty ?? false;
}

bool isValidLastName(String? lastName) {
  return lastName?.trim().isNotEmpty ?? false;
}

bool isValidDisplayName(String? displayName) {
  return displayName?.trim().isNotEmpty ?? false;
}

bool isValidImagePath(File? image) {
  if (image == null) {
    return false;
  } else {
    return image.path
        .isNotEmpty;
  }
}

bool isTripNameValid(String? tripName) {
  if(tripName == null){
    return false;
  } else {
    return tripName
        .trim()
        .isNotEmpty;
  }
}

bool isTripTypeValid(String? tripType) {
  if(tripType == null){
    return false;
  } else {
    return tripType
        .trim()
        .isNotEmpty;
  }
}
bool isTripImageValid(File? tripType) {
  return tripType?.path.isNotEmpty ?? false;
}
