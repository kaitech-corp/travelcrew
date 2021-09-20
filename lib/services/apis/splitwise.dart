import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:splitwise_api/splitwise_api.dart';
import 'package:travelcrew/services/functions/tc_functions.dart';


class SplitWiseHelper {
  saveTokens(TokensHelper tokens) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('tokens',[tokens.token,tokens.tokenSecret]);
  }

  getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tokens');
  }
}

void splitWiseAPI({String verifier}) async {
  SplitWiseService splitWiseService =
  SplitWiseService.initialize(dotenv.env['consumerKey'], dotenv.env['consumerSecret']);
  
  /// SplitWiseHelper is for saving and retrieving from shared storage
  SplitWiseHelper splitWiseHelper = SplitWiseHelper();
  if (await splitWiseHelper.getTokens() == null) {
    if(verifier == null){
      var authURL =  await splitWiseService.validateClient();
      var param = await TCFunctions().launchURL2(authURL);
    } else {
      var authURL =  await splitWiseService.validateClient();
      TokensHelper tokens = await splitWiseService.validateClient(
          verifier: verifier);
      print(tokens.token);
      await splitWiseHelper.saveTokens(tokens);

      splitWiseService.validateClient(tokens: tokens);
    }

  } else {
    var x = await SplitWiseHelper().getTokens();
    print('Tokens from Shared Preferences: $x');
    TokensHelper tokens = await SplitWiseHelper().getTokens();
    splitWiseService.validateClient(
        tokens: tokens);
    //Example
    // CurrentUserEntity currentUserEntity = await splitWiseService.getCurrentUser();
    // print(currentUserEntity.first_name);
  }
}