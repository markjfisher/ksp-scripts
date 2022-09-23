local tr is import("lib/transfer").
local tr_km is import("lib/tr_kerbin_mun.ks").
local mission is import("lib/mission").
local descent is import("lib/descent").
local launch is improot("launch").

local TGT_ALT is 82000.
local TGT_MUNALT is 20000.
local TGT_RETALT is 35000.
local RENT_BURNALT is 100000.
local PASS_COUNT is 6.
local SKIP_EVA is true.

local fr is tr:freeze.
local warping is false.

local m is mission({ parameter seq, ev, next.
  seq:add({
    launch:exec(0, TGT_ALT / 1000, false).
    next().
  }).

  seq:add({
    local trd is tr_km:calc(). local dv is trd[0]. local t is choose time:seconds + 360 if trd[1] = 0 else trd[1].
    tr:seek_SOI(Mun, TGT_MUNALT, t, dv).
    tr:exec(true).
    next().
  }).

  seq:add({
    if body <> Mun and eta:transition > 60 { warpto(time:seconds + eta:transition). }
    if body = Mun next().
  }).

  seq:add({
    if body = Mun { wait 20.
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
  }).
  seq:add({
    if SKIP_EVA {
      print "no eva, skipping #2".
      wait 2.
      next().
    } else {
      if ship:crew():length = PASS_COUNT next().
    }
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
    tr:seek_SOI(Kerbin, TGT_RETALT).
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
      wait 30.
      tr:seek(fr(time:seconds + 120), fr(0), fr(0), 0, { parameter mnv. return -abs(mnv:orbit:periapsis - TGT_RETALT). }).
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