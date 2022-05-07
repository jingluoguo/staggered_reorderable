<<<<<<< HEAD
[![pub package](https://img.shields.io/pub/v/staggered_reorderable.svg)](https://pub.dartlang.org/packages/staggered_reorderable)

## 效果图

[![staggered_reorderable.gif](https://s1.ax1x.com/2022/05/08/OlfKoT.gif)](https://imgtu.com/i/OlfKoT)

## Getting started

在 `pubspec.yaml` 添加如下:

```yaml
dependencies:
  ...
  staggered_reorderable: <latest_version>
```

导入方式如下:

```dart
import 'package:staggered_reorderable/staggered_reorderable.dart';
```

使用方式如下:

- 定义ItemList:

```dart
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
```

- 渲染组件:

```dart
  StaggeredReorderableView.customer(children: itemAll, collation: true)
```

## 贡献

感谢我的同事大佬帮我提供思路
感谢[Flutter - 通过CustomMultiChildLayout自定义环形布局](https://juejin.cn/post/7028084846895300638)
=======
# staggered_reorderable
>>>>>>> 696af21efa9d7956241d75e6373477231525215f
