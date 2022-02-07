import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

import '../../models/custom_objects.dart';
import '../../services/database.dart';
import '../../services/functions/cloud_functions.dart';
import '../../services/widgets/reusableWidgets.dart';
import '../../size_config/size_config.dart';
import 'profile_widget.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  double defaultSize = SizeConfig.defaultSize;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          StreamBuilder(
            builder: (context, userData) {
              if (userData.hasError) {
                CloudFunction()
                    .logError('Error streaming user data for Profile Page: '
                    '${userData.error.toString()}');
              }
              if (userData.hasData) {
                final UserPublicProfile user = userData.data;

                return Stack(children: [
                  HangingImageTheme3(
                    user: user,
                  ),
                  ProfileWidget(user: user)
                ]);
              } else {
                final Faker faker = Faker();
                final UserPublicProfile blankUser = UserPublicProfile(
                    uid: faker.phoneNumber.toString(),
                    email: '',
                    urlToImage: faker.image.toString(),
                    firstName: faker.person.firstName(),
                    lastName: faker.person.lastName(),
                    displayName: faker.person.name(),
                    hometown: faker.address.city(),
                    topDestinations: [
                      faker.address.country(),
                      faker.address.country(),
                      faker.address.country()],
                    blockedList: [],
                    followers: [],
                    following: [],
                    facebookLink: '',
                    instagramLink: '',
                );
                return ProfileWidget(user: blankUser);
              }
            },
            stream: DatabaseService().currentUserPublicProfile,
          ),
        ],
      ),
    );
  }
}
