import 'package:flutter/material.dart';

import 'package:staggered_reorderable/staggered_reorderable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  List<CustomerItem> itemAll = [
    CustomerItem(0, "id_0", const Text("A"),
        crossAxisCellCount: 1, mainAxisCellCount: 1),
    CustomerItem(1, "id_1", const Text("B"),
        crossAxisCellCount: 2, mainAxisCellCount: 1),
    CustomerItem(2, "id_2",const Text("C"),
        crossAxisCellCount: 1, mainAxisCellCount: 1),
    CustomerItem(3, "id_3",const Text("D"),
        crossAxisCellCount: 2, mainAxisCellCount: 2),
    CustomerItem(4, "id_4",const Text("E"),
        crossAxisCellCount: 1, mainAxisCellCount: 1),
    CustomerItem(5, "id_5",const Text("F"),
        crossAxisCellCount: 1, mainAxisCellCount: 1),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('staggered_reorderable example app'),
        ),
        body: StaggeredReorderableView.customer(children: itemAll, collation: true),
      ),
    );
  }
}
