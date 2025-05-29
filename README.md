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
  List<ReorderableItem> itemAll = [
    ReorderableItem(trackingNumber: 0, id: "id_0", child: const Text("A"),
        crossAxisCellCount: 1, mainAxisCellCount: 1),
    ReorderableItem(trackingNumber: 1, id: "id_1", child: const Text("B"),
        crossAxisCellCount: 2, mainAxisCellCount: 1),
    ReorderableItem(trackingNumber: 2, id: "id_2", child: const Text("C"),
        crossAxisCellCount: 1, mainAxisCellCount: 1),
    ReorderableItem(trackingNumber: 3, id: "id_3", child: const Text("D"),
        crossAxisCellCount: 2, mainAxisCellCount: 2),
    ReorderableItem(trackingNumber: 4, id: "id_4", child: const Text("E"),
        crossAxisCellCount: 1, mainAxisCellCount: 1),
    ReorderableItem(trackingNumber: 5, id: "id_5", child: const Text("F"),
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
