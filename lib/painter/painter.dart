import 'dart:ui';
import 'package:flutter/rendering.dart';

final int maxStrokeOfPage = 400;

enum PenType {
  Pen_Line,
  Pen_Rectangle
}

class PenStatus {
  PenType type;
  Color color;
  double width;
}

class OncePainting {
  PenStatus status = PenStatus();
  List<Offset> points = <Offset>[];
}

class SignaturePainter extends CustomPainter {
  SignaturePainter(this.index, this.count, this.painting, this.fresh);

  var index = 0;
  var count = 0;

  var fresh = false;
  final List<OncePainting> painting;

  void paint(Canvas canvas, Size size) {
    int begin = index * maxStrokeOfPage;
    int end = (index == count-1) ? painting.length : begin+maxStrokeOfPage;

    print('index: $index, count: $count, begin: $begin, end: $end, stroke num: ' + painting.length.toString());

    for (int i = begin; i < end; i++) {
      var paint = new Paint()
        ..color = painting[i].status.color//Colors.black
        ..strokeCap = StrokeCap.round
        ..strokeWidth = painting[i].status.width;

      if (painting[i].points.length == 1) {
        canvas.drawPoints(PointMode.points, painting[i].points, paint);
      } else {
        for (int j = 0; j < painting[i].points.length - 1; j++) {
          canvas.drawLine(painting[i].points[j], painting[i].points[j + 1], paint);
//          print('color: ' + paint.color.toString() + ', width: ' + paint.strokeWidth.toString() +
//              ', p1: ' + painting[i].points[j].toString() + ', p2: ' + painting[i].points[j + 1].toString());
        }
      }
    }

    fresh = false;
  }

  //bool shouldRepaint(SignaturePainter other) => other.painting != painting;
  bool shouldRepaint(SignaturePainter other) {
    if (index == count-1)
      return other.fresh || fresh;
    else
      return false;
  }
}
