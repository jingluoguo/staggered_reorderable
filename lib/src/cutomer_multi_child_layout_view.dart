import 'package:flutter/material.dart';
import 'dart:math';

import 'item_model.dart';

/// guoshijun created this file at 2022/5/5 10:05 上午
///
/// 渲染瀑布流及支持拖拽布局

/// 最大高度
double maxHeight = 0.0;

/// 单元格大小
double itemCell = 0.0;

class CustomerMultiChildView extends StatefulWidget {
  final int columnNum;
  final List<CustomerItem> itemAll;
  final double padding;
  final Duration? duration;
  final Duration? antiShakeDuration;
  final bool collation;
  final bool canDrag;
  const CustomerMultiChildView(this.itemAll, this.columnNum, this.padding, this.canDrag,
      {Key? key,
      this.collation = false,
      this.antiShakeDuration,
      this.duration})
      : super(key: key);

  @override
  _CustomerMultiChildViewState createState() => _CustomerMultiChildViewState();
}

class _CustomerMultiChildViewState extends State<CustomerMultiChildView>
    with SingleTickerProviderStateMixin {
  /// 正在拖拽的item
  int dragItem = -1;

  /// 当前moveIndex
  int nowMoveIndex = -1;

  /// 当前接收的位置
  int nowAcceptIndex = -1;

  /// 拖拽进度
  double process = 0.0;

  List<CustomerItem> itemAll = [];

  List<CustomerItem> itemChangeAll = [];

  late AnimationController _controller;

  @override
  void initState() {
    itemAll = widget.itemAll;
    _controller = AnimationController(
      lowerBound: 0.0,
      upperBound: 1.0,
      vsync: this,
      duration: widget.duration??const Duration(milliseconds: 300),
    )..addListener(() {
        process = _controller.value;
        if (_controller.isCompleted) {
          changeItemChangeAllToItemAll();
          _controller.reset();
        }
        setState(() {});
      });
    super.initState();
  }

  /// 防抖处理
  void antiShakeProcessing(moveIndex, toIndex) {
    nowMoveIndex = moveIndex;
    nowAcceptIndex = toIndex;
    Future.delayed(widget.antiShakeDuration??const Duration(milliseconds: 100)).then((value) {
      if (nowMoveIndex == moveIndex && nowAcceptIndex == toIndex) {
        nowMoveIndex = -1;
        nowAcceptIndex = -1;
        if (!_controller.isAnimating) {
          exchangeItem(moveIndex, toIndex);
          _controller.forward();
        } else {
          _controller.reset();
          exchangeItem(moveIndex, toIndex);
          _controller.forward();
        }
      }
    });
  }

  /// 交换数据
  void exchangeItem(moveIndex, toIndex) {
    if (itemChangeAll.isEmpty) {
      for (var element in itemAll) {
        itemChangeAll.add(element);
      }
    }
    if (!widget.collation) {
      setState(() {
        var moveData =
            itemChangeAll.firstWhere((element) => element.index == moveIndex);
        var reIndex = itemChangeAll.indexOf(moveData);
        itemChangeAll.remove(moveData);
        var receiveIndex =
            itemChangeAll.indexWhere((element) => element.index == toIndex);
        if (receiveIndex >= reIndex) receiveIndex += 1;
        itemChangeAll.insert(receiveIndex, moveData);
      });
    } else {
      // print("初始状态");
      // itemChangeAll.forEach((element) {
      //   print(element.toString());
      // });
      setState(() {
        var moveData =
            itemChangeAll.firstWhere((element) => element.index == moveIndex);
        var reIndex = itemChangeAll.indexOf(moveData);
        itemChangeAll.remove(moveData);
        var receiveIndex =
            itemChangeAll.indexWhere((element) => element.index == toIndex);
        // if (receiveIndex >= reIndex) receiveIndex += 1;
        itemChangeAll.insert(receiveIndex, moveData);
        var receiveData = itemChangeAll.removeAt(receiveIndex + 1);
        itemChangeAll.insert(reIndex, receiveData);
      });
      // print("交换后状态");
      // itemChangeAll.forEach((element) {
      //   print(element.toString());
      // });
    }
  }

  changeItemChangeAllToItemAll() async {
    itemAll = itemChangeAll;
    itemChangeAll = [];
  }

  /// 子项
  Widget generateItem(int index) {
    return LayoutId(
        id: itemAll[index].id!,
        child: widget.canDrag ? LongPressDraggable(
          data: itemAll[index].index,
          child: DragTarget(
            builder: (context, candidateData, rejectedData) {
              return Container(
                width: itemAll[index].crossAxisCellCount! * itemCell,
                height: itemAll[index].mainAxisCellCount! * itemCell,
                color: Colors.grey,
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(child: itemAll[index].child),
                ),
              );
            },
            onWillAccept: (moveData) {
              // print('=== onWillAccept: $moveData ==> ${itemAll[index].index}');
              var accept = moveData != null;
              if (accept &&
                  dragItem != itemAll[index].index! &&
                  itemAll[index].index != moveData) {
                antiShakeProcessing(moveData, itemAll[index].index);
              }
              return accept;
            },
            onLeave: (moveData) {
              // print('=== onLeave: $moveData ==> ${itemAll[index].index}');
              if (moveData == nowMoveIndex) {
                nowMoveIndex = -1;
              }
              if (itemAll[index].index == nowAcceptIndex) {
                nowAcceptIndex = -1;
              }
            },
          ),
          childWhenDragging: null,
          feedback: Material(
            child: Container(
              width: itemAll[index].crossAxisCellCount! * itemCell,
              height: itemAll[index].mainAxisCellCount! * itemCell,
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: itemAll[index].child,
                ),
              ),
            ),
          ),
          onDragStarted: () {
            // print('=== onDragStarted');
            dragItem = itemAll[index].index!;
          },
          onDraggableCanceled: (Velocity velocity, Offset offset) {
            // print('=== onDraggableCanceled');
          },
          onDragCompleted: () {
            // print('=== onDragCompleted');
            dragItem = -1;
            nowAcceptIndex = -1;
            nowMoveIndex = -1;
          },
        ) : Container(
          width: itemAll[index].crossAxisCellCount! * itemCell,
          height: itemAll[index].mainAxisCellCount! * itemCell,
          color: Colors.grey,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Center(child: itemAll[index].child),
          ),
        ));
  }

  List<Widget> generateList() {
    List<Widget> list = [];
    for (var index = 0; index < itemAll.length; index++) {
      list.add(generateItem(index));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: maxHeight,
        child: CustomMultiChildLayout(
          delegate: ProxyClass(itemAll, itemChangeAll, process,
              widget.columnNum, widget.padding),
          children: generateList(),
        ),
      ),
    );
  }
}

class ProxyClass extends MultiChildLayoutDelegate {
  final List<CustomerItem> itemAll;
  final List<CustomerItem> itemChangeAll;
  final double process;
  final int columnNum;
  final double padding;

  ProxyClass(this.itemAll, this.itemChangeAll, this.process, this.columnNum,
      this.padding) {
    // 累计每列的高度
    columnH = List.generate(columnNum, (index) {
      return 0.0;
    });

    // 累计上行每列的高度
    columnLastH = List.generate(columnNum, (index) {
      return 0.0;
    });
  }

  late List columnH;
  late List columnLastH;

  /// 判断当前行是否可以存放此widget,
  /// 查到后返回index > 0
  /// 未查到返回index = -1
  int checkNowRow(Size size, double itemCell, List columnH, List columnLastH) {
    int insertIndex = -1;
    // 找到最大值
    double maxHeight = columnH.fold(
        columnH[0],
        (previousValue, element) =>
            previousValue > element ? previousValue : element);

    // 判断本行是否都已经按行放满
    for (var indexX = 0; indexX < columnH.length; indexX++) {
      if (columnH[indexX] - columnLastH[indexX] < itemCell) {
        // 判断当前点是否符合长度
        int length = size.width ~/ itemCell;
        if (columnH.length - indexX >= length) {
          insertIndex = indexX;
          for (var indexY = 0; indexY < length; indexY++) {
            if (columnH[indexY + indexX] - columnLastH[indexY + indexX] <
                itemCell) {
            } else if (maxHeight - columnH[indexY + indexX] < size.height) {
              insertIndex = -1;
              break;
            }
          }
          return insertIndex;
        }
      }
    }

    // 判断本行是否存在可以放当前widget的空隙
    for (var indexX = 0; indexX < columnH.length; indexX++) {
      // print("$indexX: $maxHeight - ${columnH[indexX]} >= ${size.height}");
      if (maxHeight - columnH[indexX] >= size.height) {
        // 判断当前点是否符合长度
        int length = size.width ~/ itemCell;
        if (columnH.length - indexX >= length) {
          insertIndex = indexX;
          for (var indexY = 0; indexY < length; indexY++) {
            if (columnH[indexY + indexX] - columnLastH[indexY + indexX] <
                itemCell) {
            } else if (maxHeight - columnH[indexY + indexX] < size.height) {
              insertIndex = -1;
              break;
            }
          }
          break;
        }
      }
    }
    // print("获取到的值：$insertIndex, 上一行高度：$columnLastH, 本行高度：$columnH");
    if (insertIndex == -1) {
      updateColumnH(columnH, columnLastH);
    }
    return insertIndex;
  }

  /// 修改columnH
  /// 将上一行高度更新成当前行的最高高度
  void updateColumnH(List columnH, List columnLastH) {
    double maxHeight = columnH.fold(
        columnH[0],
        (previousValue, element) =>
            previousValue > element ? previousValue : element);
    for (var index = 0; index < columnH.length; index++) {
      columnH[index] = maxHeight;
      columnLastH[index] = maxHeight;
    }
  }

  /// 实际计算每个item位置，
  /// 返回所有所有item信息
  List<ItemPosition> calculateFormLayout(List<CustomerItem> itemAll) {
    List<ItemPosition> calculateItemPosition = [];
    // x轴偏移量
    double offsetX = 0;

    // 当前行的index
    int nowRowIndex = 0;
    for (int i = 0; i < itemAll.length; i++) {
      // 获取当前widget宽高限制
      Size itemSize = layoutChild(
          itemAll[i].id!,
          BoxConstraints(
              minWidth: itemCell * (itemAll[i].crossAxisCellCount!) +
                  ((itemAll[i].crossAxisCellCount!) - 1) * padding,
              maxWidth: itemCell * (itemAll[i].crossAxisCellCount!) +
                  ((itemAll[i].crossAxisCellCount!) - 1) * padding,
              minHeight: itemCell * (itemAll[i].mainAxisCellCount!) +
                  ((itemAll[i].mainAxisCellCount!) - 1) * padding,
              maxHeight: itemCell * (itemAll[i].mainAxisCellCount!) +
                  ((itemAll[i].mainAxisCellCount!) - 1) * padding));

      if (true) {
        int insertIndex = checkNowRow(itemSize, itemCell, columnH, columnLastH);
        if (insertIndex == -1) {
          offsetX = 0;
          nowRowIndex = 0;
        } else {
          offsetX = insertIndex * itemCell +
              (insertIndex >= 1 ? insertIndex : 0) * padding;
          nowRowIndex = insertIndex;
        }
      }

      calculateItemPosition.add(ItemPosition(itemAll[i].id!,
          Offset(offsetX + padding * 0.5, columnH[nowRowIndex])));

      // 修改x轴偏移量
      offsetX += padding +
          itemCell * (itemAll[i].crossAxisCellCount ?? 1) +
          ((itemAll[i].crossAxisCellCount ?? 1) - 1) * padding;

      // 放置后修改当前行的index指向
      for (var c = 0; c < itemAll[i].crossAxisCellCount!; c++) {
        columnH[nowRowIndex] += itemSize.height + padding;
        if (nowRowIndex < columnNum - 1) {
          nowRowIndex++;
        }
      }
    }
    calculateItemPosition.sort((a, b) => a.id.compareTo(b.id));
    return calculateItemPosition;
  }

  /// 放置item
  void positionItem(List<ItemPosition> itemPositionList) {
    for (var element in itemPositionList) {
      /// 放置当前widget
      positionChild(element.id, element.offset);
    }
    // 刷新最高高度
    var tempHeight = 0.0;
    for (var element in columnH) {
      tempHeight = max(tempHeight, element);
    }
    if(tempHeight != 0.0){
      maxHeight = tempHeight;
    }
    columnH.clear();
    columnLastH.clear();
  }

  /// 计算偏移量
  List<ItemPosition> calculateOffset(List<ItemPosition> itemPositionList,
      List<ItemPosition> dragItemPosition) {
    List<ItemPosition> item = [];
    for (var index = 0; index < itemAll.length; index++) {
      Offset offset =
          dragItemPosition[index].transform(itemPositionList[index]);
      item.add(ItemPosition(
          itemPositionList[index].id,
          Offset(itemPositionList[index].offset.dx + offset.dx * process,
              itemPositionList[index].offset.dy + offset.dy * process)));
    }
    return item;
  }

  @override
  void performLayout(Size size) {
    double actualWidth = size.width - (columnNum + 1) * padding;

    itemCell = actualWidth / columnNum;

    List<ItemPosition> itemPositionList = calculateFormLayout(itemAll);

    if (itemChangeAll.isEmpty) {
      positionItem(itemPositionList);
    } else {
      List<ItemPosition> dragItemPosition =
          calculateDragFormLayout(itemChangeAll);
      var item = calculateOffset(itemPositionList, dragItemPosition);
      positionItem(item);
    }
  }

  @override
  bool shouldRelayout(covariant ProxyClass oldDelegate) {
    if (itemChangeAll.isEmpty || oldDelegate.itemChangeAll.isEmpty) {
      return false;
    }
    for (var index = 0; index < itemAll.length; index++) {
      bool itemEqual = oldDelegate.itemAll[index].compare(itemAll[index]);
      if (!itemEqual) {
        return true;
      }
      bool itemChangeEqual =
          oldDelegate.itemChangeAll[index].compare(itemChangeAll[index]);
      if (!itemChangeEqual) {
        return true;
      }
      bool itemCompareEqual =
          oldDelegate.itemAll[index].compare(itemChangeAll[index]);
      if (!itemCompareEqual) {
        return true;
      }
    }
    if (oldDelegate.process != process) {
      return true;
    }
    return false;
  }

  /// 计算拖拽排序后的item位置(拖拽)
  List<ItemPosition> calculateDragFormLayout(List<CustomerItem> itemChangeAll) {
    List<ItemPosition> calculateItemPosition = [];

    // 累计每列的高度
    List columnH = List.generate(columnNum, (index) {
      return 0.0;
    });

    // 累计上行每列的高度
    List columnLastH = List.generate(columnNum, (index) {
      return 0.0;
    });

    // x轴偏移量
    double offsetX = 0;

    // 当前行的index
    int nowRowIndex = 0;
    for (int i = 0; i < itemChangeAll.length; i++) {
      // 获取当前widget宽高限制
      Size itemSize = getSize(BoxConstraints(
          minWidth: itemCell * (itemChangeAll[i].crossAxisCellCount!) +
              ((itemChangeAll[i].crossAxisCellCount!) - 1) * padding,
          maxWidth: itemCell * (itemChangeAll[i].crossAxisCellCount!) +
              ((itemChangeAll[i].crossAxisCellCount!) - 1) * padding,
          minHeight: itemCell * (itemChangeAll[i].mainAxisCellCount!) +
              ((itemChangeAll[i].mainAxisCellCount!) - 1) * padding,
          maxHeight: itemCell * (itemChangeAll[i].mainAxisCellCount!) +
              ((itemChangeAll[i].mainAxisCellCount!) - 1) * padding));

      // 当前widget横向排布后越界处理
      if (true) {
        int insertIndex = checkNowRow(itemSize, itemCell, columnH, columnLastH);
        if (insertIndex == -1) {
          offsetX = 0;
          nowRowIndex = 0;
        } else {
          offsetX = insertIndex * itemCell +
              (insertIndex >= 1 ? insertIndex : 0) * padding;
          nowRowIndex = insertIndex;
        }
      }

      calculateItemPosition.add(ItemPosition(itemChangeAll[i].id!,
          Offset(offsetX + padding * 0.5, columnH[nowRowIndex])));

      // 修改x轴偏移量
      offsetX += padding +
          itemCell * (itemChangeAll[i].crossAxisCellCount ?? 1) +
          ((itemChangeAll[i].crossAxisCellCount ?? 1) - 1) * padding;

      // 放置后修改当前行的index指向
      for (var c = 0; c < itemChangeAll[i].crossAxisCellCount!; c++) {
        columnH[nowRowIndex] += itemSize.height + padding;
        if (nowRowIndex < columnNum - 1) {
          nowRowIndex++;
        }
      }
    }
    calculateItemPosition.sort((a, b) => a.id.compareTo(b.id));
    return calculateItemPosition;
  }
}
