local tr is import("lib/transfer").
local mission is import("lib/mission").
local descent is import("lib/descent").

local TGT_RETALT is 35000.
local RENT_BURNALT is 100000.

local fr is tr:freeze.
local warping is false.

// Parameters to blocks:
// a = target altitude around body to achieve and circ before transfer to kerbin

local m is mission({ parameter seq, ev, next.
  seq:add({
    parameter a.

    // get into orbit
    lock steering to heading(90, 90).
    lock throttle to 1.
    wait 2.
    lock steering to heading(90, 45).
    wait until apoapsis > a.
    lock throttle to 0.
    gear off.
    ag1 off.

    // circularize at apo as we just took off
    tr:circ_apo(50, 20).

    // run transfer to Kerbin - generic height
    local bms is addons:astrogator:calculateBurns(Kerbin).
    // adjust to true target
    tr:seek_SOI(Kerbin, TGT_RETALT, bms[0]:atTime, 0, 2, bms).
    tr:exec(true, 20).
    next().
  }).

  seq:add({
    parameter a.
    local tr_time is time:seconds + eta:transition.
    warpto(tr_time).
    wait until time:seconds >= tr_time.
    next().
  }).

  seq:add({
    parameter a.
    if body = Kerbin {
      wait 10.
      tr:seek(fr(time:seconds + 120), fr(0), fr(0), 0, 2, list(), { parameter mnv. return -abs(mnv:orbit:periapsis - TGT_RETALT). }).
      tr:exec(true, 20).
      next().
    } else {
      wait 0.5.
    }
  }).

  seq:add({
    parameter a.
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