import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/split_cost_service.dart';
import 'ui/split_item_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (BuildContext context) => SplitCostService()),
      ],
      child: MaterialApp(
        title: 'Split Costs',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SplitItemListScreen(),
      ),
    );
  }
}
