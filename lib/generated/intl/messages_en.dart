// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "agreement": MessageLookupByLibrary.simpleMessage(
            "By pressing Signup you are agreeing to our Term\'s of Service and Privacy Policy."),
        "display_name": MessageLookupByLibrary.simpleMessage("Display Name"),
        "dont_have_an_account":
            MessageLookupByLibrary.simpleMessage("Don\'t have an account?"),
        "email": MessageLookupByLibrary.simpleMessage("Email"),
        "first_name": MessageLookupByLibrary.simpleMessage("First Name"),
        "forgot_password":
            MessageLookupByLibrary.simpleMessage("Forgot Password"),
        "invalid_email": MessageLookupByLibrary.simpleMessage("Invalid Email"),
        "invalid_password":
            MessageLookupByLibrary.simpleMessage("Invalid Password"),
        "last_name": MessageLookupByLibrary.simpleMessage("Last Name"),
        "logging_in": MessageLookupByLibrary.simpleMessage("Logging In..."),
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "login_failed": MessageLookupByLibrary.simpleMessage("Login Failed"),
        "password": MessageLookupByLibrary.simpleMessage("Password"),
        "privacy_policy":
            MessageLookupByLibrary.simpleMessage("Privacy Policy"),
        "select_photo":
            MessageLookupByLibrary.simpleMessage("Select a Profile Picture"),
        "sign_up": MessageLookupByLibrary.simpleMessage("Sign Up"),
        "sign_up_or_sign_in":
            MessageLookupByLibrary.simpleMessage("Sign Up or Login with"),
        "terms_of_service":
            MessageLookupByLibrary.simpleMessage("Terms of Service"),
        "title": MessageLookupByLibrary.simpleMessage("Travel Crew")
      };
}
