import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math';

import 'item_model.dart';

/// guoshijun created this file at 2022/5/5 10:05 上午
///
/// 渲染瀑布流及支持拖拽布局

class CustomerMultiChildView extends StatefulWidget {
  final int columnNum;
  final List<ReorderableItem> children;
  final double spacing;
  final Duration duration;
  final Duration antiShakeDuration;
  final bool collation;
  final bool canDrag;
  final Axis scrollDirection;
  final double forwardRedundancy;
  final double backwardRedundancy;
  final double scrollStep;
  final Function(List<int>)? onReorder;
  const CustomerMultiChildView(
    this.children,
    this.columnNum,
    this.spacing,
    this.duration,
    this.antiShakeDuration,
    this.canDrag,
    this.forwardRedundancy,
    this.backwardRedundancy,
    this.scrollStep, {
    Key? key,
    this.collation = false,
    this.scrollDirection = Axis.vertical,
    this.onReorder,
  }) : super(key: key);

  @override
  _CustomerMultiChildViewState createState() => _CustomerMultiChildViewState();
}

class _CustomerMultiChildViewState extends State<CustomerMultiChildView>
    with SingleTickerProviderStateMixin {
  double get forwardRedundancy => widget.forwardRedundancy;
  double get backwardRedundancy => widget.backwardRedundancy;
  double get scrollStep => widget.scrollStep;

  /// 正在拖拽的item
  int dragItem = -1;

  /// 当前moveIndex
  int nowMoveIndex = -1;

  /// 当前接收的位置
  int nowAcceptIndex = -1;

  /// 拖拽进度
  double process = 0.0;

  List<ReorderableItem> itemAll = [];

  List<ReorderableItem> itemChangeAll = [];

  late AnimationController _controller;

  late ScrollController _scrollController;

  late GlobalKey _globalKey;

  Timer? _timer;

  /// 单元格大小
  double itemCell = 0.0;

  @override
  void initState() {
    _globalKey = GlobalKey();
    itemAll = widget.children;
    _controller = AnimationController(
      lowerBound: 0.0,
      upperBound: 1.0,
      vsync: this,
      duration: widget.duration,
    )..addListener(() {
        process = _controller.value;
        if (_controller.isCompleted) {
          changeItemChangeAllToItemAll();
          _controller.reset();
        }
        setState(() {});
      });
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CustomerMultiChildView oldWidget) {
    if (oldWidget.children.length != widget.children.length) {
      itemAll = widget.children;
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _startScroll = false;
  bool _isScrolling = false;

  // 跟手滑动相关代码
  void _autoScrollToUp() async {
    if (_isScrolling) return;
    _isScrolling = true;
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (!_startScroll) {
        _timer?.cancel();
        return;
      }

      var newPosition = _scrollController.offset - scrollStep;
      if (newPosition < 0) {
        newPosition = 0;
      }
      _scrollController.jumpTo(newPosition);
      if (newPosition == 0) {
        _stopScroll();
      }
    });
  }

  void _autoScrollToDown() async {
    if (_isScrolling) return;
    _isScrolling = true;
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (!_startScroll) {
        _timer?.cancel();
        return;
      }

      var newPosition = _scrollController.offset + scrollStep;
      if (newPosition > _scrollController.position.maxScrollExtent) {
        newPosition = _scrollController.position.maxScrollExtent;
      }
      _scrollController.jumpTo(newPosition);
      if (newPosition == _scrollController.position.maxScrollExtent) {
        _stopScroll();
      }
    });
  }

  void _startUpScroll() {
    _startScroll = true;
    _autoScrollToUp();
  }

  void _startDownScroll() {
    _startScroll = true;
    _autoScrollToDown();
  }

  void _stopScroll() {
    _startScroll = false;
    _isScrolling = false;
    _timer?.cancel();
  }

  void _autoScroll(DragUpdateDetails details) {
    RenderBox renderBox =
        _globalKey.currentContext!.findRenderObject() as RenderBox;
    Rect box = renderBox.localToGlobal(Offset.zero) & renderBox.size;

    var offsetForward = 0.0;
    var offsetBackward = 0.0;
    if (widget.scrollDirection == Axis.vertical) {
      offsetForward = details.localPosition.dy - box.top - forwardRedundancy;
      offsetBackward =
          details.localPosition.dy + backwardRedundancy - box.bottom;
    } else {
      offsetForward = details.localPosition.dx - box.left - forwardRedundancy;
      offsetBackward =
          details.localPosition.dx + backwardRedundancy - box.right;
    }
    if (offsetForward < 0) {
      _startUpScroll();
    } else if (offsetBackward > 0) {
      _startDownScroll();
    } else {
      _stopScroll();
    }
  }

  /// 防抖处理
  void antiShakeProcessing(moveIndex, toIndex) {
    nowMoveIndex = moveIndex;
    nowAcceptIndex = toIndex;
    Future.delayed(widget.antiShakeDuration).then((value) {
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
        var moveData = itemChangeAll
            .firstWhere((element) => element.trackingNumber == moveIndex);
        var reIndex = itemChangeAll.indexOf(moveData);
        itemChangeAll.remove(moveData);
        var receiveIndex = itemChangeAll
            .indexWhere((element) => element.trackingNumber == toIndex);
        if (receiveIndex >= reIndex) receiveIndex += 1;
        itemChangeAll.insert(receiveIndex, moveData);
      });
    } else {
      // print("初始状态");
      // itemChangeAll.forEach((element) {
      //   print(element.toString());
      // });
      setState(() {
        var moveData = itemChangeAll
            .firstWhere((element) => element.trackingNumber == moveIndex);
        var reIndex = itemChangeAll.indexOf(moveData);
        itemChangeAll.remove(moveData);
        var receiveIndex = itemChangeAll
            .indexWhere((element) => element.trackingNumber == toIndex);
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

  void reset(int index) {
    dragItem = -1;
    nowAcceptIndex = -1;
    nowMoveIndex = -1;
    _stopScroll();
    if (itemAll[index].placeholder != null) {
      setState(() {});
    }
  }

  /// 子项
  Widget generateItem(int index) {
    return LayoutId(
        id: itemAll[index].id,
        child: widget.canDrag
            ? LongPressDraggable(
                data: itemAll[index].trackingNumber,
                child: DragTarget(
                  builder: (context, candidateData, rejectedData) {
                    return SizedBox(
                      width: itemAll[index].crossAxisCellCount! * itemCell,
                      height: itemAll[index].mainAxisCellCount! * itemCell,
                      child: Center(
                          child: dragItem == itemAll[index].trackingNumber
                              ? itemAll[index].placeholder ??
                                  itemAll[index].child
                              : itemAll[index].child),
                    );
                  },
                  onWillAcceptWithDetails: (details) {
                    /// 交换过程中，忽略模块自身接收的能力，防止频繁抖动
                    if (_controller.isAnimating) {
                      return false;
                    }
                    var accept = details.data != null;
                    if (accept &&
                        dragItem != itemAll[index].trackingNumber &&
                        itemAll[index].trackingNumber != details.data) {
                      antiShakeProcessing(
                          details.data, itemAll[index].trackingNumber);
                    }
                    return accept;
                  },
                  onLeave: (moveData) {
                    // print('=== onLeave: $moveData ==> ${itemAll[index].index}');
                    if (moveData == nowMoveIndex) {
                      nowMoveIndex = -1;
                    }
                    if (itemAll[index].trackingNumber == nowAcceptIndex) {
                      nowAcceptIndex = -1;
                    }
                  },
                ),
                childWhenDragging: null,
                feedback: Material(
                  color: Colors.transparent,
                  child: SizedBox(
                    width: itemAll[index].crossAxisCellCount! * itemCell,
                    height: itemAll[index].mainAxisCellCount! * itemCell,
                    child: Center(
                      child: itemAll[index].feedback ?? itemAll[index].child,
                    ),
                  ),
                ),
                onDragStarted: () {
                  // print('=== onDragStarted');
                  dragItem = itemAll[index].trackingNumber;
                },
                onDraggableCanceled: (Velocity velocity, Offset offset) {
                  // print('=== onDraggableCanceled');
                  reset(index);
                },
                onDragUpdate: (details) => _autoScroll(details),
                onDragCompleted: () {
                  // print('=== onDragCompleted');
                  reset(index);

                  /// 排序完成后才回调，防止在排序过程中多次回调
                  List<int> tns = [];
                  for (var i in itemAll) {
                    tns.add(i.trackingNumber);
                  }
                  widget.onReorder?.call(tns);
                },
              )
            : SizedBox(
                width: itemAll[index].crossAxisCellCount! * itemCell,
                height: itemAll[index].mainAxisCellCount! * itemCell,
                child: Center(child: itemAll[index].child),
              ));
  }

  List<Widget> generateList() {
    List<Widget> list = [];
    for (var index = 0; index < itemAll.length; index++) {
      list.add(generateItem(index));
    }
    return list;
  }

  double _maxScrollHeight = 0.0;
  double _maxScrollWidth = 0.0;

  @override
  Widget build(BuildContext context) {
    if (widget.scrollDirection == Axis.vertical) {
      _maxScrollWidth = MediaQuery.of(context).size.width;
      var width = MediaQuery.of(context).size.width;
      itemCell =
          (width - (widget.columnNum + 1) * widget.spacing) / widget.columnNum;
    } else {
      _maxScrollHeight = MediaQuery.of(context).size.height;
      itemCell = (_maxScrollHeight - (widget.columnNum + 1) * widget.spacing) /
          widget.columnNum;
    }
    return SingleChildScrollView(
      key: _globalKey,
      scrollDirection: widget.scrollDirection,
      controller: _scrollController,
      child: SizedBox(
        height: _maxScrollHeight,
        width: _maxScrollWidth,
        child: CustomMultiChildLayout(
          delegate: widget.scrollDirection == Axis.vertical
              ? ProxyVerticalClass(
                  itemAll,
                  itemChangeAll,
                  process,
                  widget.columnNum,
                  widget.spacing,
                  itemCell, callback: (value) {
                  if (value == _maxScrollHeight) return;

                  /// 需要强行刷新一下，防止滑动区域有问题
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _maxScrollHeight = value;
                    });
                  });
                })
              : ProxyHorizontalClass(
                  itemAll,
                  itemChangeAll,
                  process,
                  widget.columnNum,
                  widget.spacing,
                  itemCell, callback: (value) {
                  /// 需要强行刷新一下，防止滑动区域有问题
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _maxScrollWidth = value;
                    });
                  });
                }),
          children: generateList(),
        ),
      ),
    );
  }
}

/// [Axis.vertical]
class ProxyVerticalClass extends MultiChildLayoutDelegate {
  final List<ReorderableItem> itemAll;
  final List<ReorderableItem> itemChangeAll;
  final double process;
  final int columnNum;
  final double spacing;
  final double itemCell;
  final Function(double value)? callback;

  ProxyVerticalClass(this.itemAll, this.itemChangeAll, this.process,
      this.columnNum, this.spacing, this.itemCell,
      {this.callback}) {
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
  int checkNowRow(Size size, List columnH, List columnLastH) {
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
  List<ItemPosition> calculateFormLayout(List<ReorderableItem> itemAll) {
    List<ItemPosition> calculateItemPosition = [];
    // x轴偏移量
    double offsetX = 0;

    // 当前行的index
    int nowRowIndex = 0;
    for (int i = 0; i < itemAll.length; i++) {
      // 获取当前widget宽高限制
      Size itemSize = layoutChild(
          itemAll[i].id,
          BoxConstraints(
              minWidth: itemCell * (itemAll[i].crossAxisCellCount!) +
                  ((itemAll[i].crossAxisCellCount!) - 1) * spacing,
              maxWidth: itemCell * (itemAll[i].crossAxisCellCount!) +
                  ((itemAll[i].crossAxisCellCount!) - 1) * spacing,
              minHeight: itemCell * (itemAll[i].mainAxisCellCount!) +
                  ((itemAll[i].mainAxisCellCount!) - 1) * spacing,
              maxHeight: itemCell * (itemAll[i].mainAxisCellCount!) +
                  ((itemAll[i].mainAxisCellCount!) - 1) * spacing));

      if (true) {
        int insertIndex = checkNowRow(itemSize, columnH, columnLastH);
        if (insertIndex == -1) {
          offsetX = 0;
          nowRowIndex = 0;
        } else {
          offsetX = insertIndex * itemCell +
              (insertIndex >= 1 ? insertIndex : 0) * spacing;
          nowRowIndex = insertIndex;
        }
      }

      calculateItemPosition.add(ItemPosition(itemAll[i].id,
          Offset(offsetX + spacing * 0.5, columnH[nowRowIndex])));

      // 修改x轴偏移量
      offsetX += spacing +
          itemCell * (itemAll[i].crossAxisCellCount ?? 1) +
          ((itemAll[i].crossAxisCellCount ?? 1) - 1) * spacing;

      // 放置后修改当前行的index指向
      for (var c = 0; c < itemAll[i].crossAxisCellCount!; c++) {
        columnH[nowRowIndex] += itemSize.height + spacing;
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
    callback?.call(tempHeight);
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
  bool shouldRelayout(covariant ProxyVerticalClass oldDelegate) {
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
  List<ItemPosition> calculateDragFormLayout(
      List<ReorderableItem> itemChangeAll) {
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
              ((itemChangeAll[i].crossAxisCellCount!) - 1) * spacing,
          maxWidth: itemCell * (itemChangeAll[i].crossAxisCellCount!) +
              ((itemChangeAll[i].crossAxisCellCount!) - 1) * spacing,
          minHeight: itemCell * (itemChangeAll[i].mainAxisCellCount!) +
              ((itemChangeAll[i].mainAxisCellCount!) - 1) * spacing,
          maxHeight: itemCell * (itemChangeAll[i].mainAxisCellCount!) +
              ((itemChangeAll[i].mainAxisCellCount!) - 1) * spacing));

      // 当前widget横向排布后越界处理
      if (true) {
        int insertIndex = checkNowRow(itemSize, columnH, columnLastH);
        if (insertIndex == -1) {
          offsetX = 0;
          nowRowIndex = 0;
        } else {
          offsetX = insertIndex * itemCell +
              (insertIndex >= 1 ? insertIndex : 0) * spacing;
          nowRowIndex = insertIndex;
        }
      }

      calculateItemPosition.add(ItemPosition(itemChangeAll[i].id,
          Offset(offsetX + spacing * 0.5, columnH[nowRowIndex])));

      // 修改x轴偏移量
      offsetX += spacing +
          itemCell * (itemChangeAll[i].crossAxisCellCount ?? 1) +
          ((itemChangeAll[i].crossAxisCellCount ?? 1) - 1) * spacing;

      // 放置后修改当前行的index指向
      for (var c = 0; c < itemChangeAll[i].crossAxisCellCount!; c++) {
        columnH[nowRowIndex] += itemSize.height + spacing;
        if (nowRowIndex < columnNum - 1) {
          nowRowIndex++;
        }
      }
    }
    calculateItemPosition.sort((a, b) => a.id.compareTo(b.id));
    return calculateItemPosition;
  }
}

/// [Axis.horizontal]
class ProxyHorizontalClass extends MultiChildLayoutDelegate {
  final List<ReorderableItem> itemAll;
  final List<ReorderableItem> itemChangeAll;
  final double process;
  final int columnNum;
  final double spacing;
  final double itemCell;
  final Function(double value)? callback;

  ProxyHorizontalClass(this.itemAll, this.itemChangeAll, this.process,
      this.columnNum, this.spacing, this.itemCell,
      {this.callback}) {
    // 累计每行的宽度
    rowW = List.generate(columnNum, (index) {
      return 0.0;
    });

    // 累计上行每行的宽度
    rowLastW = List.generate(columnNum, (index) {
      return 0.0;
    });

    // itemCell = containerHeight / columnNum;
  }

  late List rowW;
  late List rowLastW;

  /// 修改rowW
  /// 将上一行宽度更新成当前行的最大宽度
  void updateRowW(List rowW, List rowLastW) {
    double maxHeight = rowW.fold(
        rowW[0],
        (previousValue, element) =>
            previousValue > element ? previousValue : element);
    for (var index = 0; index < rowW.length; index++) {
      rowW[index] = maxHeight;
      rowLastW[index] = maxHeight;
    }
  }

  /// 判断当前列是否可以存放此widget,
  /// 查到后返回index > 0
  /// 未查到返回index = -1
  int checkNowColumn(Size size, double itemCell, List rowW, List rowLastW) {
    int insertIndex = -1;
    // 找到最大值
    double maxWidth = rowW.fold(
        rowW[0],
        (previousValue, element) =>
            previousValue > element ? previousValue : element);

    // 判断本列是否都已经按列放满
    for (var indexY = 0; indexY < rowW.length; indexY++) {
      if (rowW[indexY] - rowLastW[indexY] < itemCell) {
        // 判断当前点是否符合长度
        int length = size.height ~/ itemCell;
        if (rowW.length - indexY >= length) {
          insertIndex = indexY;
          for (var indexX = 0; indexX < length; indexX++) {
            if (rowW[indexY + indexX] - rowLastW[indexY + indexX] < itemCell) {
            } else if (maxWidth - rowW[indexY + indexX] < size.width) {
              insertIndex = -1;
              break;
            }
          }
          return insertIndex;
        }
      }
    }

    // 判断本列是否存在可以放当前widget的空隙
    for (var indexY = 0; indexY < rowW.length; indexY++) {
      // print("$indexX: $maxHeight - ${columnH[indexX]} >= ${size.height}");
      if (maxWidth - rowW[indexY] >= size.width) {
        // 判断当前点是否符合长度
        int length = size.height ~/ itemCell;
        if (rowW.length - indexY >= length) {
          insertIndex = indexY;
          for (var indexX = 0; indexX < length; indexX++) {
            if (rowW[indexY + indexX] - rowLastW[indexY + indexX] < itemCell) {
            } else if (maxWidth - rowW[indexY + indexX] < size.width) {
              insertIndex = -1;
              break;
            }
          }
          break;
        }
      }
    }
    if (insertIndex == -1) {
      updateRowW(rowW, rowLastW);
    }
    return insertIndex;
  }

  /// 放置item
  void positionItem(List<ItemPosition> itemPositionList) {
    for (var element in itemPositionList) {
      /// 放置当前widget
      positionChild(element.id, element.offset);
    }
    // 刷新最大宽度
    var tempWidth = 0.0;
    for (var element in rowW) {
      tempWidth = max(tempWidth, element);
    }
    callback?.call(tempWidth);
    rowW.clear();
    rowLastW.clear();
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

  /// 计算每个item位置
  List<ItemPosition> calculateFormLayout(List<ReorderableItem> itemAll) {
    List<ItemPosition> calculateItemPosition = [];

    // Y轴偏移量
    double offsetY = 0;

    // 当前列的index
    int nowColumIndex = 0;
    for (int i = 0; i < itemAll.length; i++) {
      // 获取当前widget宽高限制
      Size itemSize = layoutChild(
          itemAll[i].id,
          BoxConstraints(
              minWidth: itemCell * (itemAll[i].crossAxisCellCount!) +
                  ((itemAll[i].crossAxisCellCount!) - 1) * spacing,
              maxWidth: itemCell * (itemAll[i].crossAxisCellCount!) +
                  ((itemAll[i].crossAxisCellCount!) - 1) * spacing,
              minHeight: itemCell * (itemAll[i].mainAxisCellCount!) +
                  ((itemAll[i].mainAxisCellCount!) - 1) * spacing,
              maxHeight: itemCell * (itemAll[i].mainAxisCellCount!) +
                  ((itemAll[i].mainAxisCellCount!) - 1) * spacing));

      // 当前widget竖排布后越界处理
      if (true) {
        int insertIndex = checkNowColumn(itemSize, itemCell, rowW, rowLastW);
        if (insertIndex == -1) {
          offsetY = 0;
          nowColumIndex = 0;
        } else {
          offsetY = insertIndex * itemCell +
              (insertIndex >= 1 ? insertIndex : 0) * spacing;
          nowColumIndex = insertIndex;
        }
      }

      calculateItemPosition.add(ItemPosition(
          itemAll[i].id, Offset(rowW[nowColumIndex], offsetY + spacing * 0.5)));

      // 修改y轴偏移量
      offsetY += spacing +
          itemCell * (itemAll[i].crossAxisCellCount ?? 1) +
          ((itemAll[i].crossAxisCellCount ?? 1) - 1) * spacing;

      // 放置后修改当前行的index指向
      for (var c = 0; c < itemAll[i].mainAxisCellCount!; c++) {
        rowW[nowColumIndex] += itemSize.width + spacing;
        if (nowColumIndex < columnNum - 1) {
          nowColumIndex++;
        }
      }
    }
    calculateItemPosition.sort((a, b) => a.id.compareTo(b.id));
    return calculateItemPosition;
  }

  @override
  void performLayout(Size size) {
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
  bool shouldRelayout(covariant ProxyHorizontalClass oldDelegate) {
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
  List<ItemPosition> calculateDragFormLayout(
      List<ReorderableItem> itemChangeAll) {
    List<ItemPosition> calculateItemPosition = [];

    // 累计每列的高度
    List rowW = List.generate(columnNum, (index) {
      return 0.0;
    });

    // 累计上行每列的高度
    List rowLastW = List.generate(columnNum, (index) {
      return 0.0;
    });

    // y轴偏移量
    double offsetY = 0;

    // 当前列的index
    int nowColumIndex = 0;
    for (int i = 0; i < itemChangeAll.length; i++) {
      // 获取当前widget宽高限制
      Size itemSize = getSize(BoxConstraints(
          minWidth: itemCell * (itemChangeAll[i].crossAxisCellCount!) +
              ((itemChangeAll[i].crossAxisCellCount!) - 1) * spacing,
          maxWidth: itemCell * (itemChangeAll[i].crossAxisCellCount!) +
              ((itemChangeAll[i].crossAxisCellCount!) - 1) * spacing,
          minHeight: itemCell * (itemChangeAll[i].mainAxisCellCount!) +
              ((itemChangeAll[i].mainAxisCellCount!) - 1) * spacing,
          maxHeight: itemCell * (itemChangeAll[i].mainAxisCellCount!) +
              ((itemChangeAll[i].mainAxisCellCount!) - 1) * spacing));

      // 当前widget竖排布后越界处理
      if (true) {
        int insertIndex = checkNowColumn(itemSize, itemCell, rowW, rowLastW);
        if (insertIndex == -1) {
          offsetY = 0;
          nowColumIndex = 0;
        } else {
          offsetY = insertIndex * itemCell +
              (insertIndex >= 1 ? insertIndex : 0) * spacing;
          nowColumIndex = insertIndex;
        }
      }

      calculateItemPosition.add(ItemPosition(itemChangeAll[i].id,
          Offset(rowW[nowColumIndex], offsetY + spacing * 0.5)));

      // 修改y轴偏移量
      offsetY += spacing +
          itemCell * (itemChangeAll[i].crossAxisCellCount ?? 1) +
          ((itemChangeAll[i].crossAxisCellCount ?? 1) - 1) * spacing;

      // 放置后修改当前行的index指向
      for (var c = 0; c < itemChangeAll[i].mainAxisCellCount!; c++) {
        rowW[nowColumIndex] += itemSize.width + spacing;
        if (nowColumIndex < columnNum - 1) {
          nowColumIndex++;
        }
      }
    }
    calculateItemPosition.sort((a, b) => a.id.compareTo(b.id));
    return calculateItemPosition;
  }
}
