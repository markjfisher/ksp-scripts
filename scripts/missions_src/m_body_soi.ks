local tr is import("lib/transfer").
local mission is import("lib/mission").
local launch is improot("launch").

local TGT_ALT is 82000.
local fr is tr:freeze.
local INF is 2^64.

// Parameters to blocks:
// b = target body
// a = target altitude (scalar for exact or list(lower, upper) for range, we will hohmann transfer to lower at end
// pro = true means prograde orbit

local m is mission({ parameter seq, ev, next.
  seq:add({
    parameter b, a, pro.
    if ship:status = "prelaunch" launch:exec(0, TGT_ALT / 1000, false).
    next().
  }).

  seq:add({
    parameter b, a, pro.
    local bms is addons:astrogator:calculateBurns(b).
    local r1 is tr:seek_SOI(b, a, 0, 0, 10, bms, {
      parameter mnv.
      if not (mnv:orbit:hasnextpatch and mnv:orbit:nextpatch:body = b) return -INF.
      // prograde: get an inclination under 90
      // retrograde: get an inclination over 90.
      local i is abs(mnv:orbit:nextpatch:inclination).
      return choose 0 if ((i < 90) and pro) or ((i > 90) and (not pro)) else -INF.
    }).

    // safety check
    if not r1 {
      print "Failed to get transition to target " + b.
      print 1/0.
    }

    tr:exec(true, 40).
    next().
  }).

  seq:add({
    parameter b, a, pro.
    if body <> b and eta:transition > 60 { warpto(time:seconds + eta:transition). }
    if body = b next(). else wait 0.5.
  }).

  seq:add({
    parameter b, a, pro.
    if body = b {
      wait 20.
      tr:seek(fr(time:seconds + 120), fr(0), fr(0), 0, 5, list(), {
        parameter mnv.
        if a:typename = "List" {
          local pe is mnv:orbit:periapsis.
          // Fine if we're inside boundary
          if pe >= a[0] and pe <= a[1] return 0.
          // else we want to get to the closest of the 2 boundaries from where we are
          set a to choose a[0] if pe < a[0] else a[1].
        }
        return -abs(mnv:orbit:periapsis - a).
      }).
      tr:exec(true, 30).
      next().
    }
    wait 0.2.
  }).

  seq:add({
    parameter b, a, pro.
    print "SOI entered with " + b.
    next().
  }).

}).

export(m).