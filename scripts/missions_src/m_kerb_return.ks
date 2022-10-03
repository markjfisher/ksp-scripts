local mission is import("lib/mission").
local tr is import("lib/transfer").

local TGT_RETALT is 35000.
local RENT_BURNALT is 100000.
local fr is tr:freeze.
local warping is false.

// A mission to return to Kerbin from anywhere.
local m is mission({ parameter seq, ev, next.
  seq:add({
    local bm is addons:astrogator:calculateBurns(Kerbin).
    set dv to bm[0]:totalDV.
    set t to bm[0]:atTime.
    tr:seek_SOI(Kerbin, TGT_RETALT, t, dv, 20).
    tr:exec(true, 40).
    next().
  }).

  seq:add({
    local transition_time is time:seconds + eta:transition.
    warpto(transition_time).
    wait until time:seconds >= transition_time.
    next().
  }).

  seq:add({
    if body = Kerbin {
      wait 10.
      tr:seek(fr(time:seconds + 120), fr(0), fr(0), 0, { parameter mnv. return -abs(mnv:orbit:periapsis - TGT_RETALT). }).
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
      if not warping { set warping to true. set warp to 5. } wait 0.1.
    }
  }).

  seq:add({
    if ship:altitude < RENT_BURNALT {
      ag10 off.
      lock steering to retrograde. wait 5. lock throttle to 1.
      // burn some off to slow us down, but cater for way too much DV left in the tanks
      wait until ship:maxthrust < 1.
      lock throttle to 0. stage. wait 1. lock steering to srfretrograde.
      next().
    } else {
      wait 0.5.
    }
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