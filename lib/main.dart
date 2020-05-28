import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

final int maxStrokeOfPage = 400;

Offset mappingOffset(Offset srcPos) {
  var x = srcPos.dx / 1024.0 * window.physicalSize.width;
  var y = srcPos.dy / 768.0 * window.physicalSize.height;
  return new Offset(x, y);
}

Size mappingSize(Size srcSize) {
  var w = srcSize.width / 1024.0 * window.physicalSize.width;
  var h = srcSize.height / 768.0 * window.physicalSize.height;
  return new Size(w, h);
}

double mappingWidth(double w) {
  return mappingSize(Size(w, 0)).width;
}

double mappingHeight(double h) {
  return mappingSize(Size(0, h)).height;
}

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

// lisener
//void main() => runApp(MyApp());
//
///// This Widget is the main application widget.
//class MyApp extends StatelessWidget {
//  static const String _title = 'Flutter Code Sample';
//
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      title: _title,
//      home: Scaffold(
//        appBar: AppBar(title: const Text(_title)),
//        body: Center(
//          child: MyStatefulWidget(),
//        ),
//      ),
//    );
//  }
//}
//
//class MyStatefulWidget extends StatefulWidget {
//  MyStatefulWidget({Key key}) : super(key: key);
//
//  @override
//  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
//}
//
//class _MyStatefulWidgetState extends State<MyStatefulWidget> {
//  int _downCounter = 0;
//  int _upCounter = 0;
//  double x = 0.0;
//  double y = 0.0;
//
//  void _incrementDown(PointerEvent details) {
//    _updateLocation(details);
//    setState(() {
//      _downCounter++;
//    });
//  }
//
//  void _incrementUp(PointerEvent details) {
//    _updateLocation(details);
//    setState(() {
//      _upCounter++;
//    });
//  }
//
//  void _updateLocation(PointerEvent details) {
//    setState(() {
//      x = details.position.dx;
//      y = details.position.dy;
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Container(
////      constraints: BoxConstraints.tight(Size(300.0, 200.0)),
//      child: Listener(
//        onPointerDown: _incrementDown,
//        onPointerMove: _updateLocation,
//        onPointerUp: _incrementUp,
//        child: Container(
//          color: Colors.lightBlueAccent,
//          child: Column(
//            mainAxisAlignment: MainAxisAlignment.center,
//            children: <Widget>[
//              Text(
//                  'You have pressed or released in this area this many times:'),
//              Text(
//                '$_downCounter presses\n$_upCounter releases',
//                style: Theme.of(context).textTheme.headline4,
//              ),
//              Text(
//                'The cursor is here: (${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})',
//              ),
//            ],
//          ),
//        ),
//      ),
//    );
//  }
//}

// shopping
//class Product {
//  const Product({this.name});
//  final String name;
//}
//
//typedef void CartChangedCallback(Product product, bool inCart);
//
//class ShoppingListItem extends StatelessWidget {
//  ShoppingListItem({this.product, this.inCart, this.onCartChanged})
////  : product = product,
//  :super(key: new ObjectKey(product));
//
//  final Product product;
//  final bool inCart;
//  final CartChangedCallback onCartChanged;
//
//  Color _getColor(BuildContext context) {
//    return inCart ? Colors.black54 : Theme.of(context).primaryColor;
//  }
//
//  TextStyle _getTextStyle(BuildContext context) {
//    if (!inCart) return null;
//
//    return new TextStyle(
//      color: Colors.black54,
//      decoration: TextDecoration.lineThrough
//    );
//  }
//
//  Widget build(BuildContext context) {
//    return new ListTile(
//      onTap: () {
//        onCartChanged(product, !inCart);
//      },
//      leading: new CircleAvatar(
//        backgroundColor: _getColor(context),
//        child: new Text(product.name[0]),
//      ),
//      title: new Text(product.name, style: _getTextStyle(context)),
//    );
//  }
//}
//
//class ShoppingList extends StatefulWidget {
//  ShoppingList({Key key, this.products}) : super(key: key);
//
//  final List<Product> products;
//
//  _ShoppingListState createState() => new _ShoppingListState();
//}
//
//class _ShoppingListState extends State<ShoppingList> {
//  Set<Product> _shoppingCart = new Set<Product>();
//
//  void _handleCartChanged(Product product, bool inCart) {
//    setState(() {
//      if (inCart) {
//        _shoppingCart.add(product);
//      } else {
//        _shoppingCart.remove(product);
//      }
//    });
//  }
//
//  Widget build(BuildContext context) {
//    return new Scaffold(
//      appBar: new AppBar(
//        title: new Text('Shopping List'),
//      ),
//      body: new ListView(
//        padding: new EdgeInsets.symmetric(vertical: 8),
//        children: widget.products.map((Product product) {
//          return new ShoppingListItem(
//            product: product,
//            inCart: _shoppingCart.contains(product),
//            onCartChanged: _handleCartChanged
//          );
//        }).toList()
//      ),
//    );
//  }
//}
//
//void main() {
//  runApp(new MaterialApp(
//    title: 'Shopping App',
//    home: new ShoppingList(
//      products: <Product>[
//        new Product(name: 'Eggs'),
//        new Product(name: 'Flour'),
//        new Product(name: 'FlourEggs')
//      ],
//    ),
//  ));
//}

// single display and increase
//class CounterDisplay extends StatelessWidget {
//  CounterDisplay({this.count});
//
//  final int count;
//
//  Widget build(BuildContext context) {
//    return new Text('count: $count');
//  }
//}
//
//class CounterIncrementor extends StatelessWidget {
//  CounterIncrementor({this.onPressd});
//
//  final VoidCallback onPressd;
//
//  Widget build(BuildContext context) {
//    return new RaisedButton(
//      onPressed: onPressd,
//      child: new Text('Increment'),
//    );
//  }
//}
//
//class Counter extends StatefulWidget {
//  _CounterState createState() => new _CounterState();
//}
//
//class _CounterState extends State<Counter> {
//  int counter = 0;
//
//  void _increment() {
//    setState(() {
//      counter++;
//    });
//  }
//
//  Widget build(BuildContext context) {
//    return new Row(
//      children: <Widget>[
//        new CounterIncrementor(onPressd: _increment,),
//        new CounterDisplay(count: counter,)
//      ],
//    );
//  }
//}
//
//void main() {
//  runApp(new MaterialApp(
//    title: 'title',
//    home: new Counter()
//  ));
//}

// simple statefulWidget
//class Counter extends StatefulWidget {
//  _CounterState createState() => new _CounterState();
//}
//
//class _CounterState extends State<Counter> {
//  int _counter = 0;
//
//  void _increment() {
//    setState(() {
//      _counter++;
//    });
//  }
//
//  Widget build(BuildContext context) {
//    return new Column(
//      children: <Widget>[
//        new RaisedButton(
//          onPressed: _increment,
//          child: new Text('Increment', textDirection: TextDirection.ltr,),
//        ),
//        new Text('Count: $_counter', textDirection: TextDirection.ltr)
//      ],
//    );
//  }
//}
//
//void main() {
//  runApp(new MaterialApp(
//    title: 'Material title',
//    home: new Center(
//      child: new Counter(),
//    ),
//  ));
//}

// test gesture
//class MyButton extends StatelessWidget {
//  Widget build(BuildContext context) {
//    return new GestureDetector(
//      onTap: () {
//        print('MyButton was tapped.');
//      },
//      child: new Container(
//        height: 36,
//        //alignment: new Alignment(1, 1),
//        padding: EdgeInsets.all(8),
//        margin: EdgeInsets.symmetric(horizontal: 8),
//        decoration: new BoxDecoration(
//          borderRadius: new BorderRadius.circular(5),
//          color: Colors.lightGreen[300],
//        ),
//        child: new Center(
//          child: new Text('Engage', textDirection: TextDirection.ltr),
//        ),
//      ),
//    );
//  }
//}
//
//void main() {
//  runApp(new MaterialApp(
//    title: 'Material title',
//    home: new Center(
//      child: new MyButton(),
//    ),
//  ));
//}

// system MaterialApp
//void main() {
//  runApp(new MaterialApp(
//    title: 'Material title',
//    home: new TutorialHome(),
//  ));
//}
//
//class TutorialHome extends StatelessWidget {
//  Widget build(BuildContext context) {
//    return new Scaffold(
//      appBar: new AppBar(
//        leading: new IconButton(
//            icon: new Icon(Icons.menu),
//            tooltip: 'Navigation menu',
//            onPressed: null
//        ),
//        title: new Text('title'),
//        actions: <Widget>[
//          new IconButton(
//              icon: new Icon(Icons.search),
//              onPressed: null
//          ),
//          new IconButton(
//              icon: new Icon(Icons.settings),
//              onPressed: null
//          )
//        ],
//      ),
//      body: new Center(
//        child: new Text('Hello world.'),
//      ),
//      floatingActionButton: new FloatingActionButton(
//        tooltip: 'Add',
//          child: new Icon(Icons.add),
//          onPressed: null
//      ),
//    );
//  }
//}

// test appBar
//class MyAppBar extends StatelessWidget {
//  MyAppBar({this.title});
//
//  final Widget title;
//
//  Widget build(BuildContext context) {
//    return new Container(
//      height: 56,
//      padding: const EdgeInsets.symmetric(horizontal: 18),
//      decoration: new BoxDecoration(color: Colors.blue[500]),
//      child: new Row(
//        children: <Widget>[
//          new IconButton(
//              icon: new Icon(Icons.menu),
//              tooltip: "Menu",
//              onPressed: null
//          ),
//          new Expanded(child: title),
//          new IconButton(
//              icon: new Icon(Icons.search),
//              tooltip: "Search",
//              onPressed: null
//          ),
//        ],
//      ),
//    );
//  }
//}
//
//class MyScaffold extends StatelessWidget {
//  Widget build(BuildContext context) {
//    return new Material(
//      child: new Column(
//        children: <Widget>[
//          new Expanded(
//              child: new Center(
//                child: new Text('Hello World'),
//              )
//          ),
//          new MyAppBar(
//            title: new Text(
//              'Material Title',
//              style: Theme.of(context).primaryTextTheme.title,
//            ),
//          ),
//          new Container(
//            child: new Text('data'),
//            padding: EdgeInsets.all(28),
//            color: Colors.black26,
//          )
//        ],
//      ),
//    );
//  }
//}
//
//void main() {
//  runApp(new MaterialApp(
//    title: 'My app',
//    home: new MyScaffold(),
//  ));
//}