local tr is import("lib/transfer").
local mission is import("lib/mission").

local TGT_RETALT is 35000.
local RENT_BURNALT is 100000.
local fr is tr:freeze.
local warping is false.

// A mission to return to Kerbin from anywhere.
local m is mission({ parameter seq, ev, next.
  seq:add({
    if body <> Kerbin {
      local bms is addons:astrogator:calculateBurns(Kerbin).
      tr:seek_SOI(Kerbin, TGT_RETALT, bms[0]:atTime, 0, 2, bms).
      tr:exec(true, 40).
    }
    next().
  }).

  seq:add({
    if body <> Kerbin {
      local transition_time is time:seconds + eta:transition.
      warpto(transition_time).
      wait until time:seconds >= transition_time.
    }
    next().
  }).

  seq:add({
    if body = Kerbin {
      wait 10.
      tr:seek(fr(time:seconds + 120), fr(0), fr(0), 0, 10, list(), { parameter mnv. return -abs(mnv:orbit:periapsis - TGT_RETALT). }).
      tr:exec(true, 40).
      next().
    } else {
      wait 0.5.
    }
  }).

  seq:add({
    if ship:altitude < RENT_BURNALT * 10 {
      set warp to 0. wait 1. next().
    } else {
      if not warping { set warping to true. set warp to 5. }
      wait 0.1.
    }
  }).

  seq:add({
    parameter a.
    if ship:altitude < RENT_BURNALT {
      ag10 off.
      set warp to 0. set warping to false. wait 1.
      lock steering to retrograde. wait 5. lock throttle to 1.
      // we could check the high atmosphere alt here to ensure we're not burning up
      // otherwise the ship has trouble rotating to retro at the end in atmosphere.
      wait until ship:maxthrust < 1.
      lock throttle to 0.

      // kick off any additional engines towards body
      local normalVec is vcrs(ship:velocity:orbit, -body:position).
      local radialVec is vcrs(normalVec, ship:velocity:orbit).
      lock steering to radialVec.
      wait 5.

      // This assumes the final stage also contains the parachutes set to safe values so they don't get
      // destroyed in upper atmosphere
      stage. wait 2.

      lock steering to srfretrograde.
      wait 5.

      next().
    } else wait 0.5.
  }).


  seq:add({
    parameter a.
    if (ship:status = "Landed" or ship:status = "Splashed") next(). else wait 0.5.
  }).

}).

export(m).