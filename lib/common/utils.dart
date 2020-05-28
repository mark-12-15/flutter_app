import 'dart:ui';

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