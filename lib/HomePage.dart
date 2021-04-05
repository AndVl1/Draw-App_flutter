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
  Color currentColor = Color(0x000000);
  Color backgroundColor = Color(0xffffff);
  List<String> modes = ["Draw", "Line", "Rect", "Eraser"];

  List<TouchPoints> points = [];
  DrawModes mode = DrawModes.points;
  Offset startPosition = Offset(0, 0);

  double opacity = 1.0;
  StrokeCap strokeType = StrokeCap.round;
  double strokeWidth = 3.0;

  void changeColor(Color color) => setState(() => currentColor = color);

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
                      pointsList: points,
                      mode: mode,
                      startPoint: startPosition,
                    ),
                  ),
                  onPanStart: (details) {
                    setState(() {
                      RenderBox renderBox = context.findRenderObject();
                      startPosition = details.localPosition;

                      points.add(TouchPoints(
                          points:
                              renderBox.globalToLocal(details.localPosition),
                          paint: Paint()
                            ..strokeCap = strokeType
                            ..isAntiAlias = true
                            ..color = modes[selectedIndex] == "Eraser"
                                ? backgroundColor
                                : currentColor
                            ..strokeWidth = strokeWidth));
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      RenderBox renderBox = context.findRenderObject();

                      points.add(TouchPoints(
                          points:
                              renderBox.globalToLocal(details.localPosition),
                          paint: Paint()
                            ..strokeCap = strokeType
                            ..isAntiAlias = true
                            ..color = modes[selectedIndex] == "Eraser"
                                ? backgroundColor.withOpacity(opacity)
                                : currentColor.withOpacity(opacity)
                            ..strokeWidth = strokeWidth));
                    });
                  },
                  onPanEnd: (details) {
                    setState(() {
                      points.add(null);
                    });
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
                          points.clear();
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
