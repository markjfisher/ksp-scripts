if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/").
runpath("1:/knu.ks").
local tr is import("lib/transfer").
local orbit is import("lib/orbit").
local tr_km is import("lib/tr_kerbin_mun").
local freeze is tr:freeze.

parameter targetBody.

local f1 is {
  parameter tB.    // target body getting an angle to in the frame of reference of the ship's parent's plane
  local b is body. // parent to ship

  // target's vector component in parent body's plane
  local parentNormal is orbit:norm(b).
  print "norm: " + parentNormal.
  local vParentToTarget is (tB:position - b:position).
  local targetPlaneComponent is vxcl(parentNormal, vParentToTarget).
//  set aTarget to vecdraw(
//    b:position,
//    targetPlaneComponent,
//    red,
//    "target",
//    1.0, true, 0.2, true, true).

  // ship's vector component in parent body's plane
  local vShipToParent is (ship:position - b:position).
  local shipPlaneComponent is vxcl(parentNormal, vShipToParent).
//  set aShip to vecdraw(
//    ship:position,
//    b:position,
//    green,
//    "ship",
//    1.0, true, 0.2, false, true).
//  set aShipPlane to vecdraw(
//    b:position,
//    shipPlaneComponent,
//    blue,
//    "comp",
//    1.0, true, 0.2, false, true).
//  set aShipNorm to vecdraw(
//    ship:position,
//    shipPlaneComponent - vShipToParent,
//    yellow,
//    "norm",
//    1.0, true, 0.2, false, true).

  local a is vang(targetPlaneComponent, shipPlaneComponent).
  print "angle: " + a.

  local dv_x is tr_km:calc().
  print "dv: " + dv_x[0].
  print " t: " + dv_x[1].
  set new_node to node(dv_x[1], 0, 0, dv_x[0]).
  add new_node.
}.

f1(targetBody).