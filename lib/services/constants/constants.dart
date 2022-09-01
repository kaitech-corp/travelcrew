import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../size_config/size_config.dart';


/// Assets
const String error = 'assets/images/error.jpg';
const String splashScreenLogo = 'assets/images/v1.gif';
const String profileImagePlaceholder = 'assets/images/blank_profile_picture.png';
const String spaceImage = 'assets/images/space3.jpg';
const String skyImage = 'assets/images/sky.jpg';
const String travelImage = 'assets/images/travelPics.png';
const String starImage = 'assets/images/5star.png';
const String TCLogo = 'assets/images/TC_logo.png';
const String google_logo = 'assets/images/google_logo.png';
const String apple_logo = 'assets/images/apple_logo.png';
const String instagram_logo = 'assets/images/instagram2.png';
const String instagram_logo_icon = 'assets/images/instagram3.png';
const String facebook_logo = 'assets/images/facebook.png';
const String twitter_logo = 'assets/images/twitter.png';

/// Urls
const String urlToPrivacyPolicy = 'https://www.travelcrew.app/privacypolicy.html';
const String urlToTerms = 'https://www.travelcrew.app/terms&conditions.html';
const String TC_InstagramPage = 'https://www.instagram.com/travelcrew_kt/';
const String TC_FacebookPage = 'https://m.facebook.com/TravelCrew.KT';
const String TC_TwitterPage = 'https://twitter.com/TravelCrew_kt';

/// Intl messages
String agreementMessage() => Intl.message(
    "By pressing Signup you are agreeing to our Term's of Service and Privacy Policy.",
    name: 'agreementMessage',
    desc: 'Informing user they are agreeing to terms and conditions after signing up.');
String collaboratingText() => Intl.message(
    'Interested in collaborating? Email Randy@kaitechcorp.com directly.',
    name: 'collaboratingText',
    desc: 'Contact info for users interested in collaborating.');
String signUpOrSignIn() => Intl.message(
  'Sign Up or Login with',
  name: 'signUpOrSignIn',
  desc: 'Inform user to sign up or sign in using the available options.');

// Add Trip Page
String addTripNameLabel() => Intl.message('Trip name',name: 'addTripNameLabel', desc: 'Add trip page.');
String addTripNameValidator() => Intl.message('Please enter a trip name.',name: 'addTripNameValidator', desc: 'Add trip page.');
String addTripTypeLabel() => Intl.message('Type (i.e. work, vacation, wedding)',name: 'addTripTypeLabel', desc: 'Add trip page.');
String addTripTypeValidator() => Intl.message('Please enter a type.',name: 'addTripTypeValidator', desc: 'Add trip page.');
String addTripLocation() => Intl.message('Location',name: 'addTripLocation', desc: 'Add trip page.');
String addTripLocationValidator() => Intl.message('Please enter a location.',name: 'addTripLocationValidator', desc: 'Add trip page.');
String addTripPublic() => Intl.message('Public',name: 'tripPublic', desc: 'Add trip page.');
String addTripImageMessage() => Intl.message('No image selected.',name: 'tripImageMessage', desc: 'Add trip page.');
String addTripDescriptionMessage() => Intl.message('Description',name: 'tripDescriptionMessage', desc: 'Add trip page.');
String addTripAddDescriptionMessage() => Intl.message('Add a short description.',name: 'tripAddDescriptionMessage', desc: 'Add trip page.');
String addTripSavingDataMessage() => Intl.message('Saving new Trip data.',name: 'tripSavingDataMessage', desc: 'Add trip page.');
String addTripAddTripButton() => Intl.message('Add Trip',name: 'tripLocation', desc: 'Add trip page.');

// Edit Trip Page
String editTripPageTitle() => Intl.message('Edit Trip',name: 'editTripPageTitle', desc: 'Add trip page.');
String editTripPageEditLocation() => Intl.message('Edit Location',name: 'editTripPageEditLocation', desc: 'Add trip page.');

// Alert dialogs
String reportMessage() => Intl.message(
    'Submit a report and we will review this report within 24 hrs and if deemed '
        'inappropriate we will take action by removing the content and/or account '
        'within that time frame.',name: 'reportMessage');
String blockMessage() => Intl.message(
    'This user will be removed from all of your trips (public and private) and '
        'will not be able to view any of your content. Please note this user will '
        'not be removed from shared trips where neither party is the owner. It is '
        'your responsibility to exit such trips.',name: 'blockMessage');
String deleteAccountMessage() => Intl.message(
    "We're sad to see you leave. Please review our Privacy Policy on 'Data "
        "Retention' before confirming the deletion of this account.",
    name: 'deleteAccountMessage');
String forgotPassword() => Intl.message(
    "We'll send you an email with instructions to reset your password.",
    name: 'tripLocation');
String cancelMessage() => Intl.message('Cancel',name: 'cancelMessage');
String report() => Intl.message('Report',name: 'report');
String yesMessage() => Intl.message('Yes',name: 'yesMessage');
String noMessage() => Intl.message('No',name: 'noMessage');
String deleteMessage() => Intl.message('Delete?',name: 'deleteMessage');
String closeMessage() => Intl.message('Close',name: 'closeMessage');

/// Strings
const String saveEditedTripData = 'Saving edited Trip data.';

/// Lists
const List<String> modes = <String>[
  'Driving', 
  'Bike/Scooter',
  'Bus', 
  'Carpooling',
  'Flying',
  'Train',
  'Uber/Lift'];
const List<String> tabs = [
  'Explore', 
  'Split', 
  'Transportation', 
  'Lodging', 
  'Activities', 
  'Chat'];
const List<String> placeTypes = [
  'bar',
  'cafe',
  'campground',
  'park',
  'tourist',
  'zoo',
];

const String signInWithGoogle = '  Google';
const String signInWithApple = '  Apple';

const List urls = [];
const String splitWiseToken = 'splitWiseToken';



/// Durations
const Duration defaultDuration = Duration(seconds: 3);
const Duration listAnimationDuration = Duration(milliseconds: 500);

/// Doubles
double cartBarHeight = SizeConfig.screenHeight*.12;
double sizeFromHangingTheme = SizeConfig.screenHeight*.13;
const double basketHeaderHeight = 85;
const double defaultPadding = 20;
const double textBoxHeight = 120.0;

const int maxLines = 5;



///Colors
const Color canvasColor = Color(0xFFFAFAFA);


//Drawer Menu
const String currentVersion = 'v1.5.0';

/// AdminPage
const String admin = 'Admin';
const String feedback = 'Feedback';
const String submitted = 'Submitted';
const String customNotification = 'Custom Notification';
const String push = 'Push';
const String enterMessage = 'Enter a message';


