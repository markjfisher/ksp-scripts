//KOS
// diraxesdraw - Draw the XYZ axes of a given direction (rotation).
//
// Assumes you've already made a list like so:
//  SET DRAWS TO LIST().
// Before calling it the first time.
//
declare parameter dir, baseColor, scale, label.

draws:add(list()).
set colorOffset to 0.3.
draws[draws:length-1]:ADD(
  VECDRAW(
    V(0,0,0), dir*V(1,0,0) * scale,
    RGB( baseColor:RED+colorOffset, baseColor:GREEN-colorOffset, baseColor:BLUE-colorOffset ),
    label + " X", 1, true )
  ).
draws[draws:length-1]:ADD(
  VECDRAW(
    V(0,0,0), dir*V(0,1,0) * scale,
    RGB( baseColor:RED-colorOffset, baseColor:GREEN+colorOffset, baseColor:BLUE-colorOffset ),
    label + " Y", 1, true )
  ).
draws[draws:length-1]:ADD(
  VECDRAW(
    V(0,0,0), dir*V(0,0,1) * scale,
    RGB( baseColor:RED-colorOffset, baseColor:GREEN-colorOffset, baseColor:BLUE+colorOffset ),
    label + " Z", 1, true )
  ).

