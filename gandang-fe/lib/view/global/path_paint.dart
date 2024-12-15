import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';

import 'color_data.dart';
import 'doughnut_paint.dart';

class PathPaint {
  static PathPaint instance = PathPaint();

  Widget getPathWidget(double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomPaint(
          size: Size(height, height),
          painter: DoughnutPaint(color: ColorData.PRIMARY_COLOR),
        ),
        const SizedBox(height: 4),
        DottedLine(
          direction: Axis.vertical,
          lineLength: height,
          lineThickness: 1.5,
          dashGapLength: 1.5,
          dashColor: ColorData.CONTENTS_100,
        ),
        const SizedBox(height: 4),
        CustomPaint(
          size: Size(height, height),
          painter: DoughnutPaint(color: ColorData.SECONDARY_06),
        )
      ],
    );
  }
}