local mission is import("lib/mission").
local tr is import("lib/transfer").

local TGT_RETALT is 35000.
local RENT_BURNALT is 100000.
local fr is tr:freeze.
local warping is false.

local m is mission({ parameter seq, ev, next.
  seq:add({
    if body = Kerbin {
      wait 30. tr:seek(
        fr(time:seconds + 120), fr(0), fr(0), 0,
        { parameter mnv. return -abs(mnv:orbit:periapsis - TGT_RETALT). }).
      tr:exec(true).
      next().
    }
  }).

  seq:add({
    if ship:altitude < RENT_BURNALT * 10 { set warp to 0. wait 1. next().
    } else {
      if not warping { set warping to true. set warp to 5. } wait 0.1.
    }
  }).

  seq:add({
    if ship:altitude < RENT_BURNALT {
      ag10 off.
      lock steering to retrograde. wait 5. lock throttle to 1.
      wait until ship:maxthrust < 1.
      lock throttle to 0. stage. wait 1. lock steering to srfretrograde.
      next().
    }
  }).

  seq:add({ if ship:status = "Landed" next(). }).

}).

export(m).