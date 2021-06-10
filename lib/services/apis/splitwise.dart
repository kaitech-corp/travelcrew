library splitwise_api;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:splitwise_api/splitwise_api.dart';



void SplitwiseAPI() async {
  await dotenv.load(fileName: ".env");
  SplitWiseService splitWiseService =
  SplitWiseService.initialize(dotenv.env['consumerKey'], dotenv.env['consumerSecret']);

  /// SplitWiseHelper is for saving and retrieving from shared storage
  SplitWiseHelper splitWiseHelper = SplitWiseHelper();
  var tok = await splitWiseHelper.getTokens();
  if (tok == null) {
    var authURL = splitWiseService.validateClient();
    //This Will print the token and also return them and save them to Shared Prefs
    TokensHelper tokens = await splitWiseService.validateClient(
        verifier: 'theTokenYouGetAfterAuthorization');

    await splitWiseHelper.saveTokens(tokens);

    splitWiseService.validateClient(tokens: tokens);
  } else {
    print('Got here');
    splitWiseService.validateClient(
        tokens: await splitWiseHelper.getTokens());
    //Example
    CurrentUserEntity currentUserEntity = await splitWiseService
        .getCurrentUser();
    print(currentUserEntity.user.first_name);
  }
}

class SplitWiseHelper {
  saveTokens(TokensHelper tokens) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('tokens',[tokens.token,tokens.tokenSecret]);
  }

  getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    print('From getTokens function: ${prefs.getString('tokens')}');
    return prefs.getString('tokens');
  }
}