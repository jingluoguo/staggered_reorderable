import 'package:flutter/material.dart';

/// guoshijun created this file at 2022/5/5 11:58 上午
///
/// 子项model
class ReorderableItem {
  int trackingNumber;
  String id;
  int? crossAxisCellCount;
  int? mainAxisCellCount;
  Widget child;

  ReorderableItem(
      {required this.trackingNumber,
      required this.id,
      required this.child,
      this.crossAxisCellCount = 1,
      this.mainAxisCellCount = 1});

  bool compare(ReorderableItem next) {
    if (id == next.id &&
        crossAxisCellCount == next.crossAxisCellCount &&
        mainAxisCellCount == next.mainAxisCellCount &&
        child == next.child) {
      return true;
    }
    return false;
  }

  void changeToValue(ReorderableItem item) {
    id = item.id;
    mainAxisCellCount = item.mainAxisCellCount;
    crossAxisCellCount = item.crossAxisCellCount;
    child = item.child;
  }

  @override
  String toString() {
    return "trackingNumber: $trackingNumber, id: $id, crossAxisCellCount: $crossAxisCellCount, mainAxisCellCount: $mainAxisCellCount, child: $child";
  }
}

/// 存储定位
class ItemPosition {
  String id;
  Offset offset;

  ItemPosition(this.id, this.offset);

  @override
  String toString() {
    return "id: $id, offset: $offset";
  }

  bool compare(ItemPosition next) {
    if (id == next.id &&
        offset.dx == next.offset.dx &&
        offset.dy == next.offset.dy) {
      return true;
    }
    return false;
  }

  Offset transform(ItemPosition old) {
    double dx = 0.0;
    double dy = 0.0;
    if (id == old.id) {
      dx = offset.dx - old.offset.dx;
      dy = offset.dy - old.offset.dy;
    }
    return Offset(dx, dy);
  }
}
