import 'package:flutter/material.dart';

class SplitItemListScreen extends StatelessWidget {
  const SplitItemListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Costs'),
      ),
      body: const Center(
        child: Text('Split Item List'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create split item screen
        },
        tooltip: 'Add Split Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
