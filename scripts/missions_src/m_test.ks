local tr is import("lib/transfer").
local mission is import("lib/mission").
local dbg is import("lib/ds").
local fr is tr:freeze.

local INF is 2^64.

local m is mission({ parameter seq, ev, next.
  seq:add({
    parameter b, a.
    local bms is addons:astrogator:calculateBurns(b).
    tr:seek_SOI(b, a, 0, 0, 20, bms, {
      parameter mnv.
      return choose 0 if (mnv:orbit:hasnextpatch and mnv:orbit:nextpatch:body = b) else -INF.
    }).

    local an is allnodes.
    if not hasnode or not (an[an:length - 1]:orbit:hasnextpatch and an[an:length - 1]:orbit:nextpatch:body = b) {
      dbg:out("Failed to get SOI to: " + b).
      print 1/0.
    }

    print "running nodes with true!".
    tr:exec(true, 40).
    next().
  }).

  seq:add({
    parameter b, a.
    if body <> b and eta:transition > 60 { warpto(time:seconds + eta:transition). }
    if body = b next(). else wait 0.5.
  }).

  seq:add({
    parameter b, a.
    if body = b {
      wait 20.
      tr:seek(fr(time:seconds + 120), fr(0), fr(0), 0, 5, list(), {
        parameter mnv.
        if a:typename = "List" {
          local pe is mnv:orbit:periapsis.
          // skip if we're in the boundary - HERE: can't do next. return 0?
          if pe >= a[0] and pe <= a[1] return 0.
          // else we want to get to the closest of the 2 boundaries from where we are
          set a to choose a[0] if pe < a[0] else a[1].
        }
        return -abs(mnv:orbit:periapsis - a).
      }).
      tr:exec(true, 30).
      next().
    }
    wait 0.1.
  }).

  seq:add({
    parameter b, a.
    tr:seek(fr(time:seconds + eta:periapsis), fr(0), fr(0), 0, 20, list(), { parameter mnv. return - mnv:orbit:eccentricity. }).
    tr:exec(true, 30).
    next().
  }).

}).

export(m).