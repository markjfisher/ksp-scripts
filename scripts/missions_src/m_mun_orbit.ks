local tr is import("lib/transfer").
local mission is import("lib/mission").
local launch is improot("launch").

local TGT_ALT is 82000.
local TGT_MUNALT is 250000.
local fr is tr:freeze.
local INF is 2^64.

// pro = true means prograde orbit

local m is mission({ parameter seq, ev, next.
  seq:add({
    parameter pro.
    if ship:status = "prelaunch" launch:exec(0, TGT_ALT / 1000, false).
    next().
  }).

  seq:add({
    parameter pro.
    local bm is addons:astrogator:calculateBurns(Mun).
    local t is bm[0]:atTime.
    local dv is bm[0]:totalDV * 1.01. // add 1% to the dv as a start to give it the boost to start closer to retro
    tr:seek_SOI(Mun, TGT_MUNALT, t, dv, 20, {
      parameter mnv.
      // prograde: get an inclination under 90
      // retrograde: get an inclination over 90.
      if mnv:orbit:hasnextpatch {
        if pro {
          return choose 0 if abs(mnv:orbit:nextpatch:inclination) < 90 else -INF.
        } else {
          return choose 0 if abs(mnv:orbit:nextpatch:inclination) > 90 else -INF.
        }
      }
      // no patch means it hasn't reached target
      return -INF.
    }).
    tr:exec(true).
    next().
  }).

  seq:add({
    parameter pro.
    if body <> Mun and eta:transition > 60 { warpto(time:seconds + eta:transition). }
    if body = Mun next().
    wait 0.2.
  }).

  seq:add({
    parameter pro.
    if body = Mun {
      wait 20.
      tr:seek(fr(time:seconds + 120), fr(0), fr(0), 0, { parameter mnv. return -abs(mnv:orbit:periapsis - TGT_MUNALT). }).
      tr:exec(true).
      next().
    }
    wait 0.2.
  }).

  seq:add({
    parameter pro.
    tr:seek(fr(time:seconds + eta:periapsis), fr(0), fr(0), 0, { parameter mnv. return - mnv:orbit:eccentricity. }).
    tr:exec(true).
    next().
  }).

  seq:add({
    parameter pro.
    print "mun orbit established.".
    next().
  }).

}).

export(m).