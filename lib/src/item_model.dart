import 'package:flutter/cupertino.dart';

/// guoshijun created this file at 2022/5/5 11:58 上午
///
/// 子项model
class CustomerItem {
  int? index;
  String? id;
  int? crossAxisCellCount;
  int? mainAxisCellCount;
  Widget child;

  CustomerItem(this.index, this.id, this.child,{this.crossAxisCellCount = 1, this.mainAxisCellCount = 1});

  bool compare(CustomerItem next){
    if(this.id == next.id && this.crossAxisCellCount == next.crossAxisCellCount && this.mainAxisCellCount == next.mainAxisCellCount && this.child == next.child)
      return true;
    return false;
  }

  void changeToValue(CustomerItem item){
    this.id = item.id;
    this.mainAxisCellCount = item.mainAxisCellCount;
    this.crossAxisCellCount = item.crossAxisCellCount;
    this.child = item.child;
  }

  String toString(){
    return "index: $index, id: $id, crossAxisCellCount: $crossAxisCellCount, mainAxisCellCount: $mainAxisCellCount, child: $child";
  }
}

/// 存储定位
class ItemPosition{
  String id;
  Offset offset;

  ItemPosition(this.id, this.offset);

  String toString(){
    return "id: $id, offset: $offset";
  }

  bool compare(ItemPosition next){
    if(this.id == next.id && this.offset.dx == next.offset.dx && this.offset.dy == next.offset.dy)
      return true;
    return false;
  }

  Offset transform(ItemPosition old){
    double dx = 0.0;
    double dy = 0.0;
    if(this.id == old.id){
      dx = this.offset.dx - old.offset.dx;
      dy = this.offset.dy - old.offset.dy;
    }
    return Offset(dx, dy);
  }
}