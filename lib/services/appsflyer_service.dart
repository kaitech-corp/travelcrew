// import 'package:appsflyer_sdk/appsflyer_sdk.dart';

// late AppsflyerSdk _appsflyerSdk;

// void initAppsflyer() async {
//   final AppsFlyerOptions options = AppsFlyerOptions(
//     afDevKey: "mB6VA7Um9avrUPB5ovmcGC",
//     appId: "123456789", // iOS only
//     showDebug: true,
//   );

//   _appsflyerSdk = AppsflyerSdk(options);
//   _appsflyerSdk.initSdk(
//     registerConversionDataCallback: true,
//     registerOnAppOpenAttributionCallback: true,
//     registerOnDeepLinkingCallback: true,
//   );

//   _appsflyerSdk.onDeepLinking((DeepLinkResult result) {
//     // print("Deep link received: ${result.deepLink?.toJson()}");

//     final deepLinkData = result.deepLink?.deepLinkValue;
//     // Handle the deep link navigation logic here
//   });
// }
