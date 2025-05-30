import 'dart:math';
import 'package:flutter/material.dart';
import 'package:staggered_reorderable/staggered_reorderable.dart';

void main() {
  runApp(MyAPP());
}

class MyAPP extends StatelessWidget {
  MyAPP({super.key});

  final crossList = List.generate(20, (_) => Random().nextInt(2) + 1);
  final mainList = List.generate(20, (_) => Random().nextInt(2) + 1);

  Widget _body() {
    List<ReorderableItem> children = [];
    for (int i = 0; i < 20; i++) {
      children.add(ReorderableItem(
        trackingNumber: i,
        id: '$i',
        crossAxisCellCount: crossList[i],
        mainAxisCellCount: mainList[i],
        child: Center(child: Text('$i')),
      ));
    }
    return StaggeredReorderableView.customer(children: children, columnNum: 4);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Example'),
        ),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: _body(),
        ),
      ),
    );
  }
}
