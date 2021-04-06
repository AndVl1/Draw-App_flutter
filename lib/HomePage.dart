import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'DrawModes.dart';
import 'Painter.dart';
import 'TouchPoints.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;
  Color currentColor = Colors.black;
  Color backgroundColor = Colors.white;
  List<String> modes = ["Draw", "Line", "Rect", "Eraser"];

  List<Paint> paints = [];
  List<Path> paths = [];
  Path latestPath;
  Paint latestPaint;

  DrawModes mode = DrawModes.points;
  Offset startPosition = Offset(0, 0);

  double opacity = 1.0;
  StrokeCap strokeType = StrokeCap.round;
  double strokeWidth = 8.0;

  void changeColor(Color color) => setState(() => currentColor = color);

  void initPaintAndPen(Color color) {
    latestPaint = getNewPaint(color);
    latestPath = Path();
    paints.add(latestPaint);
    paths.add(latestPath);
  }

  Paint getNewPaint(Color color) {
    return Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = strokeType
      ..isAntiAlias = true
      ..color = color
      ..strokeWidth = strokeWidth
    ;
  }

  void startPath(Offset offset) {
    switch (mode) {
      case DrawModes.points:
        initPaintAndPen(currentColor);
        latestPath.moveTo(offset.dx, offset.dy);
        break;
      case DrawModes.line:
      case DrawModes.rect:
        initPaintAndPen(currentColor);
        startPosition = offset;
        break;
      case DrawModes.eraser:
        initPaintAndPen(backgroundColor);
        latestPath.moveTo(offset.dx, offset.dy);
        break;
    }
  }

  void updatePath(Offset offset) {
    log("update");
    switch (mode) {
      case DrawModes.points:
      case DrawModes.eraser:
        latestPath.lineTo(offset.dx, offset.dy);
        break;
      case DrawModes.line:
        latestPath = Path();
        latestPaint = getNewPaint(currentColor);
        paths.removeLast();
        paints.removeLast();
        paths.add(latestPath);
        paints.add(latestPaint);
        latestPath.moveTo(startPosition.dx, startPosition.dy);
        latestPath.lineTo(offset.dx, offset.dy);
        break;
      case DrawModes.rect:
        latestPath = Path();
        latestPaint = getNewPaint(currentColor);
        paths.removeLast();
        paints.removeLast();
        paths.add(latestPath);
        paints.add(latestPaint);
        latestPath.moveTo(startPosition.dx, startPosition.dy);
        latestPath.lineTo(startPosition.dx, offset.dy);
        latestPath.lineTo(offset.dx, offset.dy);
        latestPath.lineTo(offset.dx, startPosition.dy);
        latestPath.lineTo(startPosition.dx, startPosition.dy);
        break;
    }
  }

  void endPath(Offset offset) {
    switch (mode) {
      case DrawModes.points:
      case DrawModes.eraser:
        break;
      case DrawModes.line:
        initPaintAndPen(currentColor);
        latestPath?.moveTo(startPosition.dx, startPosition.dy);
        latestPath?.lineTo(offset.dx, offset.dy);
        break;
      case DrawModes.rect:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
          color: Colors.white,
          child: Stack(
            fit: StackFit.passthrough,
            alignment: AlignmentDirectional.topCenter,
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                child: GestureDetector(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: Painter(
                      paths: paths,
                      paints: paints,
                      latestPath: latestPath,
                      latestPaint: latestPaint,
                      startPoint: startPosition,
                      currentColor: currentColor,
                    ),
                  ),
                  onPanStart: (details) {
                    setState(() {
                      RenderBox renderBox = context.findRenderObject();
                      startPath(renderBox.globalToLocal(details.localPosition));
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      RenderBox renderBox = context.findRenderObject();
                      updatePath(renderBox.localToGlobal(details.localPosition));
                    });
                  },
                  onPanEnd: (details) {
                    setState(() { });
                  },
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Wrap(
                        children: List<Widget>.generate(
                            4,
                            (index) => ChoiceChip(
                                  label: Text(modes[index]),
                                  selected: selectedIndex == index,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      selectedIndex = selected ? index : null;
                                      switch (selectedIndex) {
                                        case 0:
                                          mode = DrawModes.points;
                                          log(mode.toString());
                                          break;
                                        case 1:
                                          mode = DrawModes.line;
                                          break;
                                        case 2:
                                          mode = DrawModes.rect;
                                          break;
                                        case 3:
                                          mode = DrawModes.eraser;
                                          break;
                                      }
                                      log(mode.toString());
                                    });
                                  },
                                )),
                        spacing: 8,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    titlePadding: const EdgeInsets.all(0.0),
                                    contentPadding: const EdgeInsets.all(0.0),
                                    content: SingleChildScrollView(
                                      child: ColorPicker(
                                        pickerColor: currentColor,
                                        onColorChanged: changeColor,
                                        colorPickerWidth: 300.0,
                                        pickerAreaHeightPercent: 0.7,
                                        enableAlpha: true,
                                        displayThumbColor: true,
                                        showLabel: true,
                                        paletteType: PaletteType.hsv,
                                        pickerAreaBorderRadius:
                                            const BorderRadius.only(
                                          topLeft: const Radius.circular(2.0),
                                          topRight: const Radius.circular(2.0),
                                        ),
                                      ),
                                    ),
                                  );
                                });
                          },
                          child: Text("Color")),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          paths.clear();
                          paints.clear();
                        },
                        child: Text("Clear")),
                  ),
                ],
              ),
            ],
          ),
          margin: new EdgeInsets.symmetric(horizontal: 8.0),
          padding: new EdgeInsets.all(8.0),
        ));
  }
}
