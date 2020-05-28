import 'package:flutter/material.dart';
import 'painter/painter.dart';
import 'common/utils.dart';

class Signature extends StatefulWidget {
  SignatureState createState() => new SignatureState();
}

class SignatureState extends State<Signature> {
  var _penColor = Colors.black;
  var lstPainting = List<OncePainting>();
  var fresh = false;
  var palleteVisible = false;

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
          painting.status.color = _penColor;
          painting.status.width = 5.0;

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
            lstPainting.last.points.add(localPosition);
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
        padding: new EdgeInsets.only(left: 10, top: 500),
        child: new Row(
          children: <Widget>[
            new RaisedButton(child: Text("clear"), onPressed: () {lstPainting.clear();}),
            new RaisedButton(
                child: Text("pallete"),
                onPressed: () {
                  setState(() {
                    palleteVisible=!palleteVisible;
                  });
                }
            ),
          ],
        )
    )];
  }

  _buildPallete() {
    if (palleteVisible) {
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
                _penColor=lstColor[index];
                return false;
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
