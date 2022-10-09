local tr is import("lib/transfer").
local mission is import("lib/mission").
local descent is import("lib/descent").
local launch is improot("launch").

local LAUNCH_ALT is 82000.
local INF is 2^64.

local fr is tr:freeze.
local warping is false.

// Parameters to blocks:
// b = target body
// a = target altitude (scalar for exact or list(lower, upper) for range, we will hohmann transfer to lower at end

local m is mission({ parameter seq, ev, next.
  seq:add({
    parameter b, a.
      if ship:status = "prelaunch" launch:exec(0, LAUNCH_ALT / 1000, false).
    next().
  }).

  seq:add({
    parameter b, a.
    local bms is addons:astrogator:calculateBurns(b).
    tr:seek_SOI(b, a, 0, 0, 2, bms, {
      parameter mnv.
      if not (mnv:orbit:hasnextpatch and mnv:orbit:nextpatch:body = b) return -INF.
      // ensure we're prograde wrt target.
      return choose 0 if abs(mnv:orbit:nextpatch:inclination) < 90 else -INF.
    }).

    // safety check, but this may not be needed. keep until tested very far planets
    local an is allnodes.
    if not hasnode or not (an[an:length - 1]:orbit:hasnextpatch and an[an:length - 1]:orbit:nextpatch:body = b) {
      print "Failed to get SOI to: " + b.
      print 1/0.
    }

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

  // circ and reduce to target altitude
  seq:add({
    parameter b, a.
    tr:circ_per(5, 40).

    local ta is choose a[0] if a:typename = "List" else a.
    // we may not need to do hohmann if we are already at target
    local p_apo is abs(orbit:periapsis / ta - 1).
    local p_per is abs(orbit:apoapsis / ta - 1).
    if (p_apo > 0.01 or p_per > 0.01) tr:hohmann(ta, 40, 2).
    next().
  }).

  // landing
  seq:add({
    parameter b, a.
    gear on.
    descent:suicide_burn(3000).
    if stage:number >= 2 {
      lock throttle to 0. wait 0.1. stage. wait 0.1.
    }
    descent:suicide_burn(50).
    descent:powered_landing().
    next().
  }).
}).

export(m).