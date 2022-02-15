// import 'dart:async';
//
// import 'activity_repository.dart';
// import 'all_users_repository.dart';
// import 'chat_repository.dart';
// import 'current_user_profile_repository.dart';
// import 'lodging_repository.dart';
// import 'notification_repository.dart';
// import 'split_repository.dart';
// import 'transportation_repository.dart';
// import 'trip_ad_repository.dart';
// import 'trip_repositories/all_trip_repository.dart';
// import 'trip_repositories/current_trip_repository.dart';
// import 'trip_repositories/favorite_trip_repository.dart';
// import 'trip_repositories/past_trip_repository.dart';
// import 'trip_repositories/private_trip_repository.dart';
// import 'user_profile_repository.dart';
// import 'user_settings_repository.dart';
//
//
//
// /// Generic Interface Firebase collection.
// /// Relies on a remote NoSQL document-oriented database.
//
// class GenericRepository<M,R> {
//
//   final StreamController<List<M>> loadedData = StreamController<
//       List<M>>.broadcast();
//
//   void dispose() {
//     loadedData.close();
//   }
//
//   void refresh({String identifier}) {
//     // Retrieve data
//     Stream<List<M>> data = repoList(identifier) as Stream<List<M>>;
//     loadedData.addStream(data);
//   }
//
//   Stream<List<M>> data() => loadedData.stream;
//
// /// List Repositories
//   dynamic repoList(String identifier) {
//     var repo = R.toString();
//     switch (repo) {
//       case 'ActivityRepository':
//         {
//           return ActivityRepository().activityDataStream(identifier);
//         }
//         break;
//
//       case 'AllUserRepository':
//         {
//           return AllUserRepository().allUsersDataStream();
//         }
//         break;
//       case 'ChatRepository':
//         {
//           return ChatRepository().chatDataStream(identifier);
//         }
//         break;
//
//       case 'AllUserRepository':
//         {
//           return AllUserRepository().allUsersDataStream();
//         }
//         break;
//       case 'CurrentUserProfileRepository':
//         {
//           return CurrentUserProfileRepository().currentUserProfileDataStream();
//         }
//         break;
//
//       case 'LodgingRepository':
//         {
//           return LodgingRepository().lodgingDataStream(identifier);
//         }
//         break;
//       case 'NotificationRepository':
//         {
//           return NotificationRepository().notificationDataStream();
//         }
//         break;
//
//       case 'SplitRepository':
//         {
//           return SplitRepository().splitDataStream(identifier);
//         }
//         break;
//       case 'TransportationRepository':
//         {
//           return TransportationRepository().transportationDataStream(identifier);
//         }
//         break;
//       case 'TripAdRepository':
//         {
//           return TripAdRepository().tripAdDataStream();
//         }
//         break;
//       case 'PublicProfileRepository':
//         {
//           return PublicProfileRepository().publicProfileDataStream(identifier);
//         }
//         break;
//
//       case 'UserSettingsRepository':
//         {
//           return UserSettingsRepository().settingsDataStream();
//         }
//         break;
//       case 'AllTripsRepository':
//         {
//           return AllTripsRepository().allTripsDataStream();
//         }
//         break;
//       case 'CurrentTripRepository':
//         {
//           return CurrentTripRepository().currentTripDataStream();
//         }
//         break;
//
//       case 'PastTripRepository':
//         {
//           return PastTripRepository().pastTripDataStream();
//         }
//         break;
//       case 'PrivateTripRepository':
//         {
//           return PrivateTripRepository().privateTripDataStream();
//         }
//         break;
//
//       case 'FavoriteTripRepository':
//         {
//           return FavoriteTripRepository().favoriteTripDataStream();
//         }
//         break;
//       default:
//         {
//           //statements;
//         }
//         break;
//     }
//   }
// }