// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: always_specify_types

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final String name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final S instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final S? instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Travel Crew`
  String get title {
    return Intl.message(
      'Travel Crew',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password`
  String get forgot_password {
    return Intl.message(
      'Forgot Password',
      name: 'forgot_password',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account?`
  String get dont_have_an_account {
    return Intl.message(
      'Don\'t have an account?',
      name: 'dont_have_an_account',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get sign_up {
    return Intl.message(
      'Sign Up',
      name: 'sign_up',
      desc: '',
      args: [],
    );
  }

  /// `Login Failed`
  String get login_failed {
    return Intl.message(
      'Login Failed',
      name: 'login_failed',
      desc: '',
      args: [],
    );
  }

  /// `Logging In...`
  String get logging_in {
    return Intl.message(
      'Logging In...',
      name: 'logging_in',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Email`
  String get invalid_email {
    return Intl.message(
      'Invalid Email',
      name: 'invalid_email',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Password`
  String get invalid_password {
    return Intl.message(
      'Invalid Password',
      name: 'invalid_password',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up or Login with`
  String get sign_up_or_sign_in {
    return Intl.message(
      'Sign Up or Login with',
      name: 'sign_up_or_sign_in',
      desc: '',
      args: [],
    );
  }

  /// `Display Name`
  String get display_name {
    return Intl.message(
      'Display Name',
      name: 'display_name',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get first_name {
    return Intl.message(
      'First Name',
      name: 'first_name',
      desc: '',
      args: [],
    );
  }

  /// `Last Name`
  String get last_name {
    return Intl.message(
      'Last Name',
      name: 'last_name',
      desc: '',
      args: [],
    );
  }

  /// `Select a Profile Picture`
  String get select_photo {
    return Intl.message(
      'Select a Profile Picture',
      name: 'select_photo',
      desc: '',
      args: [],
    );
  }

  /// `By pressing Signup you are agreeing to our Term's of Service and Privacy Policy.`
  String get agreement {
    return Intl.message(
      'By pressing Signup you are agreeing to our Term\'s of Service and Privacy Policy.',
      name: 'agreement',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Service`
  String get terms_of_service {
    return Intl.message(
      'Terms of Service',
      name: 'terms_of_service',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacy_policy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacy_policy',
      desc: '',
      args: [],
    );
  }

  /// `By pressing Signup you are agreeing to our Term's of Service and Privacy Policy.`
  String get agreementMessage {
    return Intl.message(
      'By pressing Signup you are agreeing to our Term\'s of Service and Privacy Policy.',
      name: 'agreementMessage',
      desc: '',
      args: [],
    );
  }

  /// `Interested in collaborating? Email Randy@kaitechcorp.com directly.`
  String get collaboratingText {
    return Intl.message(
      'Interested in collaborating? Email Randy@kaitechcorp.com directly.',
      name: 'collaboratingText',
      desc: '',
      args: [],
    );
  }

  /// `Trip name`
  String get addTripNameLabel {
    return Intl.message(
      'Trip name',
      name: 'addTripNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a trip name.`
  String get addTripNameValidator {
    return Intl.message(
      'Please enter a trip name.',
      name: 'addTripNameValidator',
      desc: '',
      args: [],
    );
  }

  /// `Type (i.e. work, vacation, wedding)`
  String get addTripTypeLabel {
    return Intl.message(
      'Type (i.e. work, vacation, wedding)',
      name: 'addTripTypeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a type.`
  String get addTripTypeValidator {
    return Intl.message(
      'Please enter a type.',
      name: 'addTripTypeValidator',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get addTripLocation {
    return Intl.message(
      'Location',
      name: 'addTripLocation',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a location.`
  String get addTripLocationValidator {
    return Intl.message(
      'Please enter a location.',
      name: 'addTripLocationValidator',
      desc: '',
      args: [],
    );
  }

  /// `Public`
  String get addTripPublic {
    return Intl.message(
      'Public',
      name: 'addTripPublic',
      desc: '',
      args: [],
    );
  }

  /// `No image selected.`
  String get addTripImageMessage {
    return Intl.message(
      'No image selected.',
      name: 'addTripImageMessage',
      desc: '',
      args: [],
    );
  }

  /// `Edit image.`
  String get editTripImageMessage {
    return Intl.message(
      'Edit image.',
      name: 'editTripImageMessage',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get addTripDescriptionMessage {
    return Intl.message(
      'Description',
      name: 'addTripDescriptionMessage',
      desc: '',
      args: [],
    );
  }

  /// `Add a short description.`
  String get addTripAddDescriptionMessage {
    return Intl.message(
      'Add a short description.',
      name: 'addTripAddDescriptionMessage',
      desc: '',
      args: [],
    );
  }

  /// `Saving new Trip data.`
  String get addTripSavingDataMessage {
    return Intl.message(
      'Saving new Trip data.',
      name: 'addTripSavingDataMessage',
      desc: '',
      args: [],
    );
  }

  /// `Add Trip`
  String get addTripAddTripButton {
    return Intl.message(
      'Add Trip',
      name: 'addTripAddTripButton',
      desc: '',
      args: [],
    );
  }

  /// `Edit Trip`
  String get editTripPageTitle {
    return Intl.message(
      'Edit Trip',
      name: 'editTripPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Edit Location`
  String get editTripPageEditLocation {
    return Intl.message(
      'Edit Location',
      name: 'editTripPageEditLocation',
      desc: '',
      args: [],
    );
  }

  /// `Submit a report and we will review this report within 24 hrs and if deemed '\n        'inappropriate we will take action by removing the content and/or account '\n        'within that time frame.`
  String get reportMessage {
    return Intl.message(
      'Submit a report and we will review this report within 24 hrs and if deemed \'\n        \'inappropriate we will take action by removing the content and/or account \'\n        \'within that time frame.',
      name: 'reportMessage',
      desc: '',
      args: [],
    );
  }

  /// `This user will be removed from all of your trips (public and private) and '\n        'will not be able to view any of your content. Please note this user will '\n        'not be removed from shared trips where neither party is the owner. It is '\n        'your responsibility to exit such trips.`
  String get blockMessage {
    return Intl.message(
      'This user will be removed from all of your trips (public and private) and \'\n        \'will not be able to view any of your content. Please note this user will \'\n        \'not be removed from shared trips where neither party is the owner. It is \'\n        \'your responsibility to exit such trips.',
      name: 'blockMessage',
      desc: '',
      args: [],
    );
  }

  /// `We're sad to see you leave. Please review our Privacy Policy on 'Data "\n        "Retention' before confirming the deletion of this account.`
  String get deleteAccountMessage {
    return Intl.message(
      'We\'re sad to see you leave. Please review our Privacy Policy on \'Data "\n        "Retention\' before confirming the deletion of this account.',
      name: 'deleteAccountMessage',
      desc: '',
      args: [],
    );
  }

  /// `We'll send you an email with instructions to reset your password.`
  String get forgotPassword {
    return Intl.message(
      'We\'ll send you an email with instructions to reset your password.',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancelMessage {
    return Intl.message(
      'Cancel',
      name: 'cancelMessage',
      desc: '',
      args: [],
    );
  }

  /// `Report`
  String get report {
    return Intl.message(
      'Report',
      name: 'report',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get deleteMessage {
    return Intl.message(
      'Delete',
      name: 'deleteMessage',
      desc: '',
      args: [],
    );
  }

  /// `Delete Account`
  String get deleteAccount {
    return Intl.message(
      'Delete Account',
      name: 'deleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Delete`
  String get confirmDelete {
    return Intl.message(
      'Confirm Delete',
      name: 'confirmDelete',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get closeMessage {
    return Intl.message(
      'Close',
      name: 'closeMessage',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yesMessage {
    return Intl.message(
      'Yes',
      name: 'yesMessage',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get noMessage {
    return Intl.message(
      'No',
      name: 'noMessage',
      desc: '',
      args: [],
    );
  }

  /// `Edit Dates`
  String get editDates {
    return Intl.message(
      'Edit Dates',
      name: 'editDates',
      desc: '',
      args: [],
    );
  }

  /// `Block`
  String get block {
    return Intl.message(
      'Block',
      name: 'block',
      desc: '',
      args: [],
    );
  }

  /// `Block Account`
  String get blockAccount {
    return Intl.message(
      'Block Account',
      name: 'blockAccount',
      desc: '',
      args: [],
    );
  }

  /// `Action Completed`
  String get actionCompleted {
    return Intl.message(
      'Action Completed',
      name: 'actionCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Disable Notifications`
  String get disableNotifications {
    return Intl.message(
      'Disable Notifications',
      name: 'disableNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Please go to your device settings to disable notifications.`
  String get notificationMessage {
    return Intl.message(
      'Please go to your device settings to disable notifications.',
      name: 'notificationMessage',
      desc: '',
      args: [],
    );
  }

  /// `Clear all notifications?`
  String get clearNotifications {
    return Intl.message(
      'Clear all notifications?',
      name: 'clearNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Join requests and follow requests will also be removed.`
  String get clearNotificationMessage {
    return Intl.message(
      'Join requests and follow requests will also be removed.',
      name: 'clearNotificationMessage',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to leave this Trip?`
  String get leaveTrip {
    return Intl.message(
      'Are you sure you want to leave this Trip?',
      name: 'leaveTrip',
      desc: '',
      args: [],
    );
  }

  /// `You will no longer have access to this Trip`
  String get leaveTripMessage {
    return Intl.message(
      'You will no longer have access to this Trip',
      name: 'leaveTripMessage',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to leave this Trip?`
  String get deleteTrip {
    return Intl.message(
      'Are you sure you want to leave this Trip?',
      name: 'deleteTrip',
      desc: '',
      args: [],
    );
  }

  /// `You will no longer have access to this Trip`
  String get deleteTripMessage {
    return Intl.message(
      'You will no longer have access to this Trip',
      name: 'deleteTripMessage',
      desc: '',
      args: [],
    );
  }

  /// `Convert to Private Trip?`
  String get convertToPrivateTrip {
    return Intl.message(
      'Convert to Private Trip?',
      name: 'convertToPrivateTrip',
      desc: '',
      args: [],
    );
  }

  /// `This trip will only be visible to members.`
  String get convertToPrivateTripMessage {
    return Intl.message(
      'This trip will only be visible to members.',
      name: 'convertToPrivateTripMessage',
      desc: '',
      args: [],
    );
  }

  /// `Convert to Public Trip?`
  String get convertToPublicTrip {
    return Intl.message(
      'Convert to Public Trip?',
      name: 'convertToPublicTrip',
      desc: '',
      args: [],
    );
  }

  /// `Trip will be become visible to everyone.`
  String get convertToPublicTripMessage {
    return Intl.message(
      'Trip will be become visible to everyone.',
      name: 'convertToPublicTripMessage',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get remove {
    return Intl.message(
      'Remove',
      name: 'remove',
      desc: '',
      args: [],
    );
  }

  /// ` will no longer be able to view this trip.`
  String get removeMessage {
    return Intl.message(
      ' will no longer be able to view this trip.',
      name: 'removeMessage',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (Locale supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
