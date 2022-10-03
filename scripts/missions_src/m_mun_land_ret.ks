local tr is import("lib/transfer").
local mission is import("lib/mission").
local descent is import("lib/descent").
local launch is improot("launch").

local TGT_ALT is 82000.
local TGT_MUNALT is 20000.
local TGT_RETALT is 35000.
local RENT_BURNALT is 100000.
local PASS_COUNT is 4.
local SKIP_EVA is false.

local fr is tr:freeze.
local warping is false.

local m is mission({ parameter seq, ev, next.
  seq:add({
    if ship:status = "prelaunch" launch:exec(0, TGT_ALT / 1000, false).
    next().
  }).

  seq:add({
    local bm is addons:astrogator:calculateBurns(Mun).
    local t is bm[0]:atTime.
    local dv is bm[0]:totalDV.
    tr:seek_SOI(Mun, TGT_MUNALT, t, dv, 20).
    tr:exec(true, 20).
    next().
  }).

  seq:add({
    if body <> Mun and eta:transition > 60 { warpto(time:seconds + eta:transition). }
    if body = Mun next().
  }).

  seq:add({
    if body = Mun {
      wait 20.
      tr:seek(fr(time:seconds + 120), fr(0), fr(0), 0, { parameter mnv. return -abs(mnv:orbit:periapsis - TGT_MUNALT). }).
      tr:exec(true).
      next().
    }
    wait 0.1.
  }).

  seq:add({
    tr:seek(fr(time:seconds + eta:periapsis), fr(0), fr(0), 0, { parameter mnv. return - mnv:orbit:eccentricity. }).
    tr:exec(true).
    next().
  }).

  seq:add({
    gear on.
    descent:suicide_burn(3000).
    if stage:number >= 2 {
      lock throttle to 0. wait 0.1. stage. wait 0.1.
    }
    descent:suicide_burn(50).
    descent:powered_landing().
    next().
  }).

  // allow kerbal to plant flag then get back in. starting with 3, allow 1 out, then when they return head off
  seq:add({
    if SKIP_EVA {
      print "no eva, skipping #1".
      wait 2.
      next().
    } else {
      if ship:crew():length = (PASS_COUNT - 1) next().
    }
    wait 0.2.
  }).
  seq:add({
    if SKIP_EVA {
      print "no eva, skipping #2".
      wait 2.
      next().
    } else {
      if ship:crew():length = PASS_COUNT next().
    }
    wait 0.2.
  }).

  seq:add({
    print "taking off from mun".
    lock steering to heading(90, 90).
    lock throttle to 1.
    wait 2.
    lock steering to heading(90, 45).
    wait until apoapsis > TGT_MUNALT.
    lock throttle to 0.
    gear off.
    next().
  }).

  seq:add({
    tr:seek(fr(time:seconds + eta:apoapsis), fr(0), fr(0), 0, { parameter mnv. return -mnv:orbit:eccentricity. }).
    tr:exec(true).
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
      tr:exec(true).
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