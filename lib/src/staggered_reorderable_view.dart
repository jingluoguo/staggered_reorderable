import 'package:flutter/material.dart';
import 'cutomer_multi_child_layout_view.dart';

import 'item_model.dart';

/// guoshijun created this file at 2022/5/7 4:22 下午
///
/// 可拖拽的不规则图形瀑布流

class StaggeredReorderableView extends StatelessWidget {
  /// 布局方向[Axis.vertical] 和[Axis.horizontal]。
  /// 默认[Axis.vertical]，布局为垂直布局。
  final Axis scrollDirection;

  /// 动画时间，默认[Duration(milliseconds: 300)]。
  final Duration duration;

  /// 防抖时间，默认[Duration(milliseconds: 100)]
  final Duration antiShakeDuration;

  /// 拖拽后变换规则，[true]为交换，[false]为插入
  final bool collation;

  /// 布局的子项
  /// [ReorderableItem.id]不允许存在重复值
  /// [ReorderableItem.trackingNumber]不允许存在重复值
  final List<ReorderableItem> children;

  /// 每行个数，默认3
  final int columnNum;

  /// 边距
  final double spacing;

  /// 是否允许拖拽
  final bool canDrag;

  /// 自动滚动冗余偏移量 [Axis.vertical] 向上; [Axis.horizontal] 向左;
  final double forwardRedundancy;

  /// 自动滚动冗余偏移量 [Axis.vertical] 向下; [Axis.horizontal] 向右;
  final double backwardRedundancy;

  /// 每次自动滚动长度，默认10.0
  final double scrollStep;

  /// 每次交换完会调用此方法，获取排序后的trackingNumber列表
  final Function(List<int>)? onReorder;

  /// 创建一个可拖动的不规则图形瀑布流.
  ///
  /// [canDrag] : 控制是否允许拖动,默认为`true`.
  ///
  /// [columnNum] : 控制每行([Axis.vertical])/每列([Axis.horizontal])展示的基本单元数量,默认为每行.
  ///
  /// [scrollDirection] : 控制排版方向,默认为[Axis.vertical].
  ///
  /// [duration] : 每次交换的动画持续时间,默认0.3s.
  ///
  /// [antiShakeDuration] : 防抖时间,默认0.1s.
  ///
  /// [collation] : 拖拽交换规则,[true]为交换，[false]为插入.
  ///
  /// [forwardRedundancy] : 自动滚动冗余偏移量 [Axis.vertical] 向上; [Axis.horizontal] 向左;
  ///
  /// [backwardRedundancy] : 自动滚动冗余偏移量 [Axis.vertical] 向下; [Axis.horizontal] 向右;
  ///
  /// [scrollStep] : 每次自动滚动长度.
  ///
  const StaggeredReorderableView.customer(
      {Key? key,
      required List<ReorderableItem> children,
      Axis scrollDirection = Axis.vertical,
      Duration duration = const Duration(milliseconds: 300),
      Duration antiShakeDuration = const Duration(milliseconds: 100),
      bool collation = false,
      int columnNum = 3,
      double spacing = 5.0,
      bool canDrag = true,
      double forwardRedundancy = 40.0,
      double backwardRedundancy = 40.0,
      double scrollStep = 10.0,
      Function(List<int>)? onReorder})
      : this(
            key: key,
            children: children,
            scrollDirection: scrollDirection,
            duration: duration,
            antiShakeDuration: antiShakeDuration,
            collation: collation,
            columnNum: columnNum,
            spacing: spacing,
            canDrag: canDrag,
            forwardRedundancy: forwardRedundancy,
            backwardRedundancy: backwardRedundancy,
            scrollStep: scrollStep,
            onReorder: onReorder);

  const StaggeredReorderableView({
    Key? key,
    required this.children,
    required this.scrollDirection,
    required this.duration,
    required this.antiShakeDuration,
    required this.collation,
    required this.columnNum,
    required this.spacing,
    required this.canDrag,
    required this.forwardRedundancy,
    required this.backwardRedundancy,
    required this.scrollStep,
    this.onReorder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomerMultiChildView(
        children,
        columnNum,
        spacing,
        duration,
        antiShakeDuration,
        canDrag,
        forwardRedundancy,
        backwardRedundancy,
        scrollStep,
        collation: collation,
        scrollDirection: scrollDirection,
        onReorder: onReorder);
  }
}
