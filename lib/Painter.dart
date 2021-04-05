import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:my_first_app/DrawModes.dart';
import 'TouchPoints.dart';

class Painter extends CustomPainter {
  Painter({this.pointsList, this.mode, this.startPoint});

  List<TouchPoints> pointsList;
  List<Offset> offsetPoints = [];

  Offset startPoint;

  DrawModes mode = DrawModes.points;

  void setMode(DrawModes mode) {
    this.mode = mode;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      switch (mode) {
        case DrawModes.eraser:
        case DrawModes.points:
          if (pointsList[i] != null && pointsList[i + 1] != null) {

            //Drawing line when two consecutive points are available
            canvas.drawLine(pointsList[i].points, pointsList[i + 1].points,
                pointsList[i].paint);
          } else if (pointsList[i] != null && pointsList[i + 1] == null) {
            offsetPoints.clear();
            offsetPoints.add(pointsList[i].points);
            offsetPoints.add(Offset(
                pointsList[i].points.dx + 0.1, pointsList[i].points.dy + 0.1));

            //Draw points when two points are not next to each other
            canvas.drawPoints(PointMode.points, offsetPoints, pointsList[i].paint);
          }
          break;
        case DrawModes.line:
          if (pointsList[i] != null && pointsList[i + 1] != null) {

            //Drawing line when two consecutive points are available
            canvas.drawLine(pointsList[i].points, pointsList[i + 1].points,
                pointsList[i].paint);
          } else if (pointsList[i] != null && pointsList[i + 1] == null) {
            Path path = new Path();

            pointsList.removeLast();

            offsetPoints.add(startPoint);
            offsetPoints.add(pointsList[i].points);

            path.moveTo(startPoint.dx, startPoint.dy);
            path.lineTo(pointsList[i].points.dx, pointsList[i].points.dy);

            canvas.drawPath(path, pointsList[i].paint);
            // log(startPoint.toString());
            // canvas.drawPath(startPoint, pointsList[i].points, pointsList[i].paint);
          }
          break;
        case DrawModes.rect:
          break;
      }

    }
  }

  @override
  bool shouldRepaint(covariant Painter oldDelegate) => true;
}