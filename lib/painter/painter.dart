import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'dart:math';

final int maxStrokeOfPage = 400;

enum PenType {
  Pen_Mouse,

  Pen_Line,
  Pen_DottedLine,
  Pen_Coordinate,

  Pen_Rectangle,
  Pen_Circle,
  Pen_Triangle,
  Pen_Parallelogram,
  Pen_Rhombus,
  Pen_RegularHexagon,
}

class PenStatus {
  PenStatus({this.type, this.color, this.width});

  PenStatus clone() => new PenStatus(type: type, color: color, width: width);

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

    //print('index: $index, count: $count, begin: $begin, end: $end, stroke num: ' + painting.length.toString());

    for (int i = begin; i < end; i++) {
      if (painting[i].points.isEmpty) continue;

      var paint = new Paint()
        ..color = painting[i].status.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = painting[i].status.width
        ..style = PaintingStyle.stroke;

      print('stroke index: $i, type: '+painting[i].status.type.toString()+', point count: '+painting[i].points.length.toString());

      if (painting[i].points.length == 1) {
        canvas.drawPoints(PointMode.points, painting[i].points, paint);
      } else {
        var path = Path();
        var firstPoint = painting[i].points[0];
        path.moveTo(firstPoint.dx, firstPoint.dy);
        //print('move to: '+painting[i].points[0].toString());

        switch (painting[i].status.type) {
          case PenType.Pen_Mouse:
            for (int j = 1; j < painting[i].points.length; j++) {
              path.lineTo(painting[i].points[j].dx, painting[i].points[j].dy);
            }
            break;
          case PenType.Pen_Line:
            var lastPoint = painting[i].points.last;
            path.lineTo(lastPoint.dx, lastPoint.dy);
            break;
          case PenType.Pen_DottedLine:
            var lastPoint = painting[i].points.last;
            path.lineTo(lastPoint.dx, lastPoint.dy);

            Path dashPath = Path();
            double dashWidth = 10.0;
            double dashSpace = 5.0;
            double distance = 0.0;
            for (PathMetric pathMetric in path.computeMetrics()) {
              while (distance < pathMetric.length) {
                dashPath.addPath(
                  pathMetric.extractPath(distance, distance + dashWidth),
                  Offset.zero,
                );
                distance += dashWidth;
                distance += dashSpace;
              }
            }

            path = dashPath;
            break;
          case PenType.Pen_Rectangle:
            var lastPoint = painting[i].points.last;
            var rect = Rect.fromPoints(firstPoint, lastPoint);
            path.addRect(rect);
            break;
          case PenType.Pen_Circle:
            var lastPoint = painting[i].points.last;
            var rect = Rect.fromPoints(firstPoint, lastPoint);
            path.addOval(rect);
            break;
          case PenType.Pen_Triangle:
            var lastPoint = painting[i].points.last;
            var rect = Rect.fromPoints(firstPoint, lastPoint);
            var peakPoints = [rect.topCenter, rect.bottomLeft, rect.bottomRight];

            peakPoints.forEach((element) {
              if (element == peakPoints.first) {
                path.moveTo(element.dx, element.dy);
              }

              path.lineTo(element.dx, element.dy);

              if (element == peakPoints.last) {
                path.lineTo(peakPoints.first.dx, peakPoints.first.dy);
              }
            });
            break;
          case PenType.Pen_Parallelogram:
            var lastPoint = painting[i].points.last;
            var rect = Rect.fromPoints(firstPoint, lastPoint);
            var offWidth = rect.height / sqrt(3);

            var peakPoints = <Offset>[];
            if ((firstPoint.dx < lastPoint.dx && firstPoint.dy < lastPoint.dy)
            || (firstPoint.dx > lastPoint.dx && firstPoint.dy > lastPoint.dy)) {
              peakPoints.add(rect.topLeft);
              peakPoints.add(Offset(rect.right-offWidth, rect.top));
              peakPoints.add(rect.bottomRight);
              peakPoints.add(Offset(rect.left+offWidth, rect.bottom));
            } else {
              peakPoints.add(Offset(rect.left+offWidth, rect.top));
              peakPoints.add(rect.topRight);
              peakPoints.add(Offset(rect.right-offWidth, rect.bottom));
              peakPoints.add(rect.bottomLeft);
            }

            peakPoints.forEach((element) {
              if (element == peakPoints.first) {
                path.moveTo(element.dx, element.dy);
              }

              path.lineTo(element.dx, element.dy);

              if (element == peakPoints.last) {
                path.lineTo(peakPoints.first.dx, peakPoints.first.dy);
              }
            });
            break;
          case PenType.Pen_Rhombus:
            var lastPoint = painting[i].points.last;
            var rect = Rect.fromPoints(firstPoint, lastPoint);
            var peakPoints = [rect.topCenter, rect.centerRight, rect.bottomCenter, rect.centerLeft];

            peakPoints.forEach((element) {
              if (element == peakPoints.first) {
                path.moveTo(element.dx, element.dy);
              }

              path.lineTo(element.dx, element.dy);

              if (element == peakPoints.last) {
                path.lineTo(peakPoints.first.dx, peakPoints.first.dy);
              }
            });
            break;
          case PenType.Pen_RegularHexagon:
            var lastPoint = painting[i].points.last;
            var rect = Rect.fromPoints(firstPoint, lastPoint);
            var offWidth = rect.width / 4.0;
            var peakPoints = <Offset>[];
            peakPoints.add(Offset(rect.left+offWidth, rect.top));
            peakPoints.add(Offset(rect.right-offWidth, rect.top));
            peakPoints.add(rect.centerRight);
            peakPoints.add(Offset(rect.right-offWidth, rect.bottom));
            peakPoints.add(Offset(rect.left+offWidth, rect.bottom));
            peakPoints.add(rect.centerLeft);

            peakPoints.forEach((element) {
              if (element == peakPoints.first) {
                path.moveTo(element.dx, element.dy);
              }

              path.lineTo(element.dx, element.dy);

              if (element == peakPoints.last) {
                path.lineTo(peakPoints.first.dx, peakPoints.first.dy);
              }
            });
            break;
          default:
            break;
        }

        canvas.drawPath(path, paint);
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
