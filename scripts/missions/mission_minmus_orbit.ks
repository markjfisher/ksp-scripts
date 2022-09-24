local tr is import("lib/transfer").
local tr_k_min is import("lib/tr_kerbin_minmus.ks").
local mission is import("lib/mission").
local launch is improot("launch").

local TGT_ALT is 82000.
local TGT_BODY_ALT is 30000.
local fr is tr:freeze.

local m is mission({ parameter seq, ev, next.
  seq:add({
    launch:exec(0, TGT_ALT / 1000, false).
    next().
  }).

  seq:add({
    local trd is tr_k_min:calc(). local dv is trd[0]. local t is choose time:seconds + 360 if trd[1] = 0 else trd[1].
    tr:seek_SOI(Minmus, TGT_BODY_ALT, t, dv).
    tr:exec(true).
    next().
  }).

  seq:add({
    if body <> Minmus and eta:transition > 60 { warpto(time:seconds + eta:transition). }
    if body = Minmus next().
  }).

  seq:add({
    if body = Minmus { wait 20.
      tr:seek(fr(time:seconds + 120), fr(0), fr(0), 0, { parameter mnv. return -abs(mnv:orbit:periapsis - TGT_BODY_ALT). }).
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
    print "minmus orbit established.".
    next().
  }).

}).

export(m).