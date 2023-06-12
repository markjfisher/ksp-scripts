local tr is import("lib/transfer").
local mission is import("lib/mission").

// A mission to descend from kerbin orbit to land.
// Assumes you have enough DV to reduce orbit into atmosphere.

// Action Groups:
//  10 - Auto Deploy items from Launch script (e.g. solar panels)

local m is mission({ parameter seq, ev, next.
  seq:add({
    ag10 off.
    lock steering to retrograde. wait 20. lock throttle to 1.
    wait until ship:maxthrust < 1.
    lock throttle to 0.

    local normalVec is vcrs(ship:velocity:orbit, -body:position).
    local radialVec is vcrs(normalVec, ship:velocity:orbit).
    lock steering to radialVec.
    wait 5.

    stage. wait 2.

    lock steering to srfretrograde.
    wait 5.

    next().
  }).

  seq:add({
    if (ship:status = "Landed" or ship:status = "Splashed") {
      print "Kerbin return complete.".
      next().
    } else {
      wait 0.5.
    }
  }).

}).

export(m).