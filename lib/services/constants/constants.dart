import 'package:flutter/material.dart';

import '../../size_config/size_config.dart';

const error = 'assets/images/error.jpg';
const splashScreenLogo = 'assets/images/v1.gif';
const profileImagePlaceholder = 'assets/images/blank_profile_picture.png';
const spaceImage = 'assets/images/space3.jpg';
const skyImage = 'assets/images/sky.jpg';
const travelImage = "assets/images/travelPics.png";
const starImage = "assets/images/5star.png";
const TCLogo = "assets/images/TC_logo.png";
const urlToPrivacyPolicy = 'https://www.travelcrew.app/privacypolicy';
const urlToTerms = 'https://www.travelcrew.app/terms';
const collaboratingText = 'Interested in collaborating? Email Randy@kaitechcorp.com directly.';
const TC_InstagramPage = 'https://www.instagram.com/travelcrew_kt/';
const TC_FacebookPage = 'https://m.facebook.com/TravelCrew.KT';
const TC_TwitterPage = "https://twitter.com/TravelCrew_kt";
const agreement = "By pressing Signup you are agreeing to our Term's of Service and Privacy Policy.";
const google_logo = "assets/images/google_logo.png";
const apple_logo = "assets/images/apple_logo.png";
const instagram_logo = "assets/images/instagram2.png";
const instagram_logo_icon = "assets/images/instagram3.png";
const facebook_logo = "assets/images/facebook.png";
const twitter_logo = "assets/images/twitter.png";
const modes = <String>['Driving', 'Bike/Scooter','Bus', 'Carpooling','Flying','Train','Uber/Lift'];
const signInWithGoogle = ' Sign in with Google';
const signInWithApple = ' Sign in with Apple';
double sizeFromHangingTheme = SizeConfig.screenHeight*.13;
const urls = [];
const splitWiseToken = 'splitWiseToken';
const tabs = ['Explore', 'Split', 'Transportation', 'Lodging', 'Activities', 'Chat'];

const defaultDuration = Duration(seconds: 3);
const listAnimationDuration = Duration(milliseconds: 500);
var cartBarHeight = SizeConfig.screenHeight*.12;
double basketHeaderHeight = 85;

const placeTypes = [
  'bar',
  'cafe',
  'campground',
  'park',
  'tourist',
  'zoo',
];

/// Colors
const Color canvasColor = Color(0xFFFAFAFA);

/// Default padding.
const double defaultPadding = 20;

/// Version number for this app - For the Drawer Menu.
const String currentVersion = 'v1.5.0';

/// AdminPage
const String admin = 'Admin';
const String feedback = 'Feedback';
const String submitted = 'Submitted';
const String customNotification = 'Custom Notification';
const String push = 'Push';
const String enterMessage = "Enter a message";

const int maxLines = 5;
const double textBoxHeight = 120.0;
