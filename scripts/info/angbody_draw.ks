if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/").
runpath("1:/knu.ks").
local orbit is import("lib/orbit").

// this does same work as lib/orbit, but adds some graphics to view the vectors.

parameter po1, po2, poP, t is time:seconds.

local f1 is {
  parameter o1, o2, oP, t.

  // target's vector component in parent body's plane
  local pN is orbit:n(oP).
  local bP is oP:position.
  local v1Full is positionAt(o1, t) - bP.
  local v2Full is positionAt(o2, t) - bP.
  local v1 is vxcl(pN, v1Full:normalized).
  local v2 is vxcl(pN, v2Full:normalized).
  set vd_1 to vecdraw(o1:position, v1Full, red, "o1", 1.0, true, 0.2, true, true).
  set vd_2 to vecdraw(o2:position, o1:position, green, "o2", 1.0, true, 0.2, false, true).
  set vd_3 to vecdraw(o1:position, v2Full, blue, "comp", 1.0, true, 0.2, false, true).
  set vd_4 to vecdraw(o2:position, v2 - v1, yellow, "norm", 1.0, true, 0.2, false, true).

  local ang is vang(v1, v2).
  if vdot(v2, vxcl(v1, o1:velocity:orbit)) < 0 {
    print "got dot < 0, changing ang from " + ang + " to " + (360 - ang).
    set ang to 360 - ang.
  }
  print "angle: " + ang.
}.

f1(po1, po2, poP, t).