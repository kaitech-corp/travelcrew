//A Dart function that evenly splits the cost of an item between a list of users.

import 'package:flutter/foundation.dart';

void splitCost(int cost, List<String> users) {
  final int amountPerPerson = cost ~/ users.length;
  int remainder = cost - (amountPerPerson * users.length);
  for (int i = 0; i < users.length; i++) {
    int total = amountPerPerson;
    if (remainder > 0) {
      total += 1;
      remainder--;
    }
    if (kDebugMode) {
      print('${users[i]} owes $total');
    }
  }
}

//A function that splits the cost of an item between a list of users and updates all users on changes.

//Function to split the cost of an item between a list of users
// void splitCost(List<double> users, double cost) {
//   //Calculate the amount each user has to pay
//   double amountPerUser = cost / users.length;
//
//   //Loop through the list of users and update the amount each user has to pay
//   for (int i = 0; i < users.length; i++) {
//     users[i] = users[i] + amountPerUser;
//   }
//
//   //Print the list of users and the amount each user has to pay
//   print("The amount each user has to pay is $amountPerUser");
//   print("Updated list of users:");
//   for (int i = 0; i < users.length; i++) {
//     print("User ${i + 1}: ${users[i]}");
//   }
// }
