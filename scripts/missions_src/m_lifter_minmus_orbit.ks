local tr is import("lib/transfer").
local mission is import("lib/mission").
local launch is improot("launch").

local TGT_ALT is 82000.
local TGT_BODY_ALT is 30000.
local fr is tr:freeze.

local m is mission({ parameter seq, ev, next.
  seq:add({
    launch:exec(0, TGT_ALT / 1000, false, false). // don't circ with lifter, it will drop
    wait 1. stage. wait 2. stage. // force off lifter
    next().
  }).

  seq:add({
    // circ at apo as we just took off
    tr:circ(90, false).
    next().
  }).

  seq:add({
    local bms is addons:astrogator:calculateBurns(Mun).
    tr:seek_SOI(Minmus, TGT_BODY_ALT, bms[0]:atTime, 0, 50, bms).
    tr:exec(true, 90).
    next().
  }).

  seq:add({
    if body <> Minmus and eta:transition > 60 { warpto(time:seconds + eta:transition). }
    if body = Minmus next().
    wait 0.1.
  }).

  seq:add({
    if body = Minmus { wait 10.
      tr:seek(fr(time:seconds + 180), fr(0), fr(0), 0, 20, list(), { parameter mnv. return -abs(mnv:orbit:periapsis - TGT_BODY_ALT). }).
      rcs on. tr:exec(true, 90). rcs off.
      next().
    }
    wait 0.1.
  }).

  seq:add({
    rcs on.
    tr:circ(90).
    rcs off.
    next().
  }).

  seq:add({
    print "minmus orbit established.".
    next().
  }).

}).

export(m).