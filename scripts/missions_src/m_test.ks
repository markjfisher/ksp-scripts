local tr is import("lib/transfer").
local mission is import("lib/mission").
local dbg is import("lib/ds").
local fr is tr:freeze.

local INF is 2^64.
local RENT_BURNALT is 100000.

local m is mission({ parameter seq, ev, next.
  seq:add({
    if ship:altitude < RENT_BURNALT {
      ag10 off.
      lock steering to retrograde. wait 5. lock throttle to 1.
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
    } else wait 0.5.
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