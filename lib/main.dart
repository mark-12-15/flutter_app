import 'package:flutter/material.dart';
import 'painter/painter.dart';
import 'common/utils.dart';

class Signature extends StatefulWidget {
  SignatureState createState() => new SignatureState();
}

class SignatureState extends State<Signature> {
  PenStatus _penStatus = PenStatus(color: Colors.black, type: PenType.Pen_Line, width: 3.0);

  var lstPainting = List<OncePainting>();
  var fresh = false;
  var _palleteVisible = false;
  var _graphVisible = false;

  _buildPaint() {
    int count = lstPainting.length;
    int num = count ~/ maxStrokeOfPage + 1;
    //print('count: $count, maxStrokeOfPage: $maxStrokeOfPage, page num: $num');

    return new GestureDetector(
      onTapDown: (e) {
        setState(() {
          var painting = new OncePainting();

          RenderBox referenceBox = context.findRenderObject();
          Offset localPosition =
          referenceBox.globalToLocal(e.localPosition);
          painting.points.add(localPosition);
          painting.status = _penStatus.clone();

          lstPainting.add(painting);

          fresh = true;
        });
      },
      onPanUpdate: (e) {
        setState(() {
          RenderBox referenceBox = context.findRenderObject();
          Offset localPosition =
          referenceBox.globalToLocal(e.localPosition);

          if (lstPainting.isNotEmpty) {
            switch (lstPainting.last.status.type) {
              case PenType.Pen_Mouse:
                lstPainting.last.points.add(localPosition);
                break;
              default: // 所有图形都是两点绘制
                if (1 != lstPainting.last.points.length) {
                  lstPainting.last.points.removeLast();
                }
                lstPainting.last.points.add(localPosition);
                break;
            }
          }

          fresh=true;
        });
      },
      onTapUp: (e) {
        fresh=false;
      },
      child: new Stack(
          children: new List<Widget>.generate(num, (i) {
            //print('generate, count: $num, i: $i');
            if (0 == num) {
              return null;
            } else
              return new Padding(
                padding: new EdgeInsets.all(0),
                child: new CustomPaint(
                  size: Size.infinite,
                  isComplex: true,
                  painter: new SignaturePainter(i, num, lstPainting, fresh),
                ),
              );
          })
      ),
    );
  }

  _buildToolBar() {
    return <Widget>[
      new Padding(
        padding: new EdgeInsets.only(left: 10, top: 10),
        child: new Column(
          children: <Widget>[
            new RaisedButton(child: Text("clear"), onPressed: () {lstPainting.clear();}),
            new RaisedButton(
                child: Text("pallete"),
                onPressed: () {
                  setState(() {
                    _palleteVisible=!_palleteVisible;
                  });
                }
            ),
            new RaisedButton(child: Text("pen"), onPressed: () {_penStatus.type=PenType.Pen_Mouse;}),
            new RaisedButton(
                child: Text("graph"),
                onPressed: () {
                  setState(() {
                    _graphVisible=!_graphVisible;
                  });
                }
            ),
          ],
        )
    )];
  }

  _buildPallete() {
    if (_palleteVisible) {
      return new Container(
        margin: EdgeInsets.only(left: 200, top: 300),
        width: mappingWidth(160),
        height: mappingHeight(115),
        decoration: new BoxDecoration(
          color: Color(0xFFFF9F13),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),

        child: GridView(
          scrollDirection: Axis.vertical,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
          ),
          padding: EdgeInsets.all(15),
          children: List.generate(
            6, (index) {
            List lstColor = [Colors.red, Colors.cyan, Colors.lightGreen,
              Colors.amber, Colors.black, Colors.black26];
            return new RaisedButton(
              shape: const RoundedRectangleBorder(
                  side: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              color: lstColor[index],
              onPressed: (){
                setState(() {
                  _penStatus.color=lstColor[index];
                  _palleteVisible = false;
                });
              },
            );
          },
          ),
        ),
      );
    } else {
      return new Container();
    }
  }

  _buildGraph() {
    if (_graphVisible) {
      return new Container(
        margin: EdgeInsets.only(left: 200, top: 300),
        width: mappingWidth(160),
        height: mappingHeight(160),
        decoration: new BoxDecoration(
          color: Color(0xFFFF9F13),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),

        child: GridView(
          scrollDirection: Axis.vertical,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
          ),
          padding: EdgeInsets.all(15),
          children: List.generate(
            9, (index) {
            List lstGraph = [PenType.Pen_Rectangle, PenType.Pen_Circle, PenType.Pen_Triangle,
              PenType.Pen_Parallelogram, PenType.Pen_Rhombus, PenType.Pen_RegularHexagon,
              PenType.Pen_Coordinate, PenType.Pen_Line, PenType.Pen_DottedLine];
            List lstIconPath = ['assets/graph/rectangle.png', 'assets/graph/circle.png', 'assets/graph/triangle.png',
              'assets/graph/parallelogram.png', 'assets/graph/rhombus.png', 'assets/graph/regularHexagon.png',
              'assets/graph/coordinate.png', 'assets/graph/line.png', 'assets/graph/dottedLine.png'];

            return new IconButton(
              padding: EdgeInsets.all(0),
              highlightColor: Colors.amber,
              icon: ImageIcon(AssetImage(lstIconPath[index])),
              iconSize: 40.0,
              onPressed: (){
                setState(() {
                  _penStatus.type = lstGraph[index];
                  _graphVisible=false;
                });
              },
            );
          },
          ),
        ),
      );
    } else {
      return new Container();
    }
  }

  Widget build(BuildContext context) {
    return new Container(
        child : new Stack(
          children: <Widget>[
            _buildPaint(),
            _buildPallete(),
            _buildGraph(),
            new Stack(
                children: _buildToolBar()
            ),
        ]
      )
    );
  }
}
class DemoApp extends StatelessWidget {
  Widget build(BuildContext context) => new Scaffold(body: new Signature());
}
void main() => runApp(new MaterialApp(home: new DemoApp()));
