local tr is import("lib/transfer").
local mission is import("lib/mission").
local launch is improot("launch").

local TGT_ALT is 83000.
local TGT_MUNALT is 300000.
local TGT_RETALT is 35000.
local RENT_BURNALT is 100000.
local fr is tr:freeze.
local warping is false.

local m is mission({ parameter seq, ev, next.
  // Launch
  seq:add({
    if ship:status = "prelaunch" launch:exec(0, TGT_ALT / 1000, false).
    next().
  }).

  // Seek Mun
  seq:add({
    local bm is addons:astrogator:calculateBurns(Mun).
    local t is bm[0]:atTime.
    local dv is bm[0]:totalDV.
    tr:seek_SOI(Mun, TGT_MUNALT, t, dv, 20).
    tr:exec(true, 20).
    next().
  }).

  // Wait to enter SOI
  seq:add({
    if body <> Mun and eta:transition > 60 { warpto(time:seconds + eta:transition). }
    if body = Mun next(). else wait 0.2.
  }).

  seq:add({
    if body = Mun {
      wait 20.
      tr:seek(fr(time:seconds + 120), fr(0), fr(0), 0, { parameter mnv. return -abs(mnv:orbit:periapsis - TGT_MUNALT). }).
      tr:exec(true).
      next().
    }
    wait 0.2.
  }).

  seq:add({
    tr:seek(fr(time:seconds + eta:periapsis), fr(0), fr(0), 0, { parameter mnv. return - mnv:orbit:eccentricity. }).
    tr:exec(true, 20).
    next().
  }).

  seq:add({
    local bm is addons:astrogator:calculateBurns(Kerbin).
    tr:seek_SOI(Kerbin, TGT_RETALT, bm[0]:atTime, bm[0]:totalDV, 20).
    tr:exec(true, 20).
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
      tr:exec(true, 20).
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
      wait 0.2.
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

  seq:add({ if (ship:status = "Landed" or ship:status = "Splashed") next(). else wait 0.5. }).

}).

export(m).