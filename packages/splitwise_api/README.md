# SplitWise API for Dart [![Say Thanks!](https://img.shields.io/badge/Say%20Thanks-!-1EAEDB.svg)](https://saythanks.io/to/techysrthk%40gmail.com) [![License](https://img.shields.io/badge/license-MIT-orange.svg)](https://github.com/srthkpthk/splitwise_api/blob/master/LICENSE.md) ![GitHub stars](https://img.shields.io/github/stars/srthkpthk/splitwise_api)

A wrapper based on [SplitWise](http://dev.splitwise.com/#introduction)

- Feel free to open a PR or Issue
- Uses OAuth 1
- Data Classes Included

###  Steps
 - Get the consumerKey and consumerSecret from [Splitwise Register App](https://secure.splitwise.com/apps)
 - Check the example.dart located in example/example.dart
 
 ### Project Structure
```text
|-- .gitignore
|-- .metadata
|-- CHANGELOG.md
|-- LICENSE
|-- README.md
|-- example
|   '-- example.dart
|-- lib
|   |-- splitwise_api.dart
|   '-- src
|       '-- util
|           |-- auth
|           |   '-- splitwise_main.dart
|           |-- data
|           |   '-- model
|           |       |-- categories_entity.dart
|           |       |-- categories_entity.g.dart
|           |       |-- comments_entity.dart
|           |       | (18 more...)
|           |       |-- post_response.g.dart
|           |       |-- single_user_entity.dart
|           |       '-- single_user_entity.g.dart
|           '-- helper
|               '-- TokensHelper.dart
'-- pubspec.yaml



```
#### Usage 
- Import the package 
```yaml
dependencies:
  splitwise_api: ^2.0.0
```
- Import in the file 

```dart
import 'package:splitwise_api/splitwise_api.dart';
```
- Setup SharedPreferences or any other system to save the token and tokenSecret to keep user logged in.
     -  For Example :-
```dart
import 'package:shared_preferences/shared_preferences.dart';

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
```
- Now Use the Wrapper and save the tokens.
  - ForExample :-
```dart
import 'package:splitwise_api/splitwise_api.dart';
import 'package:splitwise_api/src/util/data/model/current_user_entity.dart';


void main() async {
  SplitWiseService splitWiseService =
  SplitWiseService.initialize(_consumerKey, _consumerSecret);

  /// SplitWiseHelper is for saving and retrieving from shared storage
  SplitWiseHelper splitWiseHelper = SplitWiseHelper();
  if (splitWiseHelper.getTokens() == null) {
    var authURL = splitWiseService.validateClient();
    print(authURL);
    //This Will print the token and also return them save them to Shared Prefs
    TokensHelper tokens = await splitWiseService.validateClient(
        verifier: 'theTokenYouGetAfterAuthorization');
    await splitWiseHelper.saveTokens(tokens);

    splitWiseService.validateClient(tokens: tokens);
  } else {
    splitWiseService.validateClient(
        tokens: /* tokens from saved */);
    //Example
    CurrentUserEntity currentUserEntity = await splitWiseService
        .getCurrentUser();
    print(currentUserEntity.user.firstName);
  }
}
```
> Hit like if it helped 

