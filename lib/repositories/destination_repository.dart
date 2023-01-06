// import 'dart:convert';
//
// import 'package:http/http.dart' as http;
//
// import '../blocs/generics/generic_bloc.dart';
// import '../models/custom_objects.dart';
//
// class DestinationRepository extends GenericBlocRepository<DestinationModel> {
//
//   @override
//   Stream<List<DestinationModel>> data() {
//
//     const String url = 'https://storage.googleapis.com/universal-code-135522.appspot.com/apis/destination_list.json';
//
//       final http.Response response = await http.get(Uri.parse(url));
//       if (200 == response.statusCode) {
//         final dynamic result = json.decode(response.body);
//         final Iterable<dynamic> list = result as Iterable<dynamic>;
//         List<DestinationModel> destinations = list.map((e) => DestinationModel.fromJSON(e as Map<String, dynamic>)).toList();
//         return destinations as Stream<List<DestinationModel>>;
//       } else {
//         final dynamic result = json.decode(response.body);
//         final Iterable<dynamic> list = result as Iterable<dynamic>;
//         List<DestinationModel> destinations = list.map((e) => DestinationModel.fromJSON(e as Map<String, dynamic>)).toList();
//         return destinations as Stream<List<DestinationModel>>;
//       }
//   }
// }
