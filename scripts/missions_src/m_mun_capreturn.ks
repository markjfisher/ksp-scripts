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
  seq:add({
    launch:exec(0, TGT_ALT / 1000, false).
    next().
  }).

  seq:add({
    local bm is addons:astrogator:calculateBurns(Mun).
    tr:seek_SOI(Mun, TGT_MUNALT, bm[0]:atTime, bm[0]:totalDV, 5).
    tr:exec(true).
    next().
  }).

  seq:add({
    if body <> Mun and eta:transition > 60 { warpto(time:seconds + eta:transition). }
    if body = Mun next().
  }).

  seq:add({
    if body = Mun {
      wait 20. tr:seek(
        fr(time:seconds + 120), fr(0), fr(0), 0,
        { parameter mnv. return -abs(mnv:orbit:periapsis - TGT_MUNALT). }).
      tr:exec(true).
      next().
    }
    wait 0.1.
  }).

  seq:add({
    tr:seek(
      fr(time:seconds + eta:periapsis), fr(0), fr(0), 0,
      { parameter mnv. return - abs(0.5 - mnv:orbit:eccentricity). }).
    tr:exec(true).
    next().
  }).

  seq:add({
    local bm is addons:astrogator:calculateBurns(Kerbin).
    set dv to bm[0]:totalDV.
    set t to bm[0]:atTime.
    tr:seek_SOI(Kerbin, TGT_RETALT, t, dv, 25, {
      parameter mnv. return -abs(2000 * (mnv:deltav:mag - dv)).
    }).
    tr:exec(true).
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
      wait until (ship:maxthrust < 1 or ship:orbit:periapsis < 0).
      lock throttle to 0. stage. wait 1. lock steering to srfretrograde.
      next().
    }
  }).

  seq:add({ if ship:status = "Landed" next(). }).

}).

export(m).