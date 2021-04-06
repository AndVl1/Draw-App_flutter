import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:my_first_app/DrawModes.dart';
import 'TouchPoints.dart';

class Painter extends CustomPainter {
  // Painter({this.pointsList, this.mode, this.startPoint});

  Painter({this.paints, this.paths, this.latestPath, this.latestPaint, this.startPoint, this.currentColor});

  List<TouchPoints> pointsList;
  List<Offset> offsetPoints = [];

  List<Paint> paints;
  List<Path> paths;
  Path latestPath;
  Paint latestPaint;
  Color currentColor;

  Offset startPoint;

  DrawModes mode = DrawModes.points;

  void setMode(DrawModes mode) {
    this.mode = mode;
  }

  @override
  void paint(Canvas canvas, Size size) {
    log(paths.length.toString());
    for (int i = 0; i < paths.length; i++) {
      canvas.drawPath(paths[i], paints[i]);
    }
  }

  @override
  bool shouldRepaint(covariant Painter oldDelegate) => true;
}