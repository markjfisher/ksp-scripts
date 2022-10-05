local tr is import("lib/transfer").
local mission is import("lib/mission").
local descent is import("lib/descent").
local launch is improot("launch").

local LAUNCH_ALT is 82000.
local TGT_RETALT is 35000.
local RENT_BURNALT is 100000.
local INF is 2^64.

local fr is tr:freeze.
local warping is false.

// Parameters to blocks:
// b = target body
// a = target altitude (scalar for exact or list(lower, upper) for range, we will hohmann transfer to lower at end
// s = skip EVA or not (true = skip, default: false)

local m is mission({ parameter seq, ev, next.
  local crewCount is ship:crew():length.
  seq:add({
    parameter b, a, s.
    if ship:status = "prelaunch" launch:exec(0, LAUNCH_ALT / 1000, false).
    next().
  }).

  seq:add({
    parameter b, a, s.
    local bms is addons:astrogator:calculateBurns(b).
    tr:seek_SOI(b, a, 0, 0, 20, bms, {
      parameter mnv.
      return choose 0 if (mnv:orbit:hasnextpatch and mnv:orbit:nextpatch:body = b) else -INF.
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
    parameter b, a, s.
    if body <> b and eta:transition > 60 { warpto(time:seconds + eta:transition). }
    if body = b next(). else wait 0.5.
  }).

  seq:add({
    parameter b, a, s.
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
    parameter b, a, s.
    tr:circ(30).

    local ta is choose a[0] if a:typename = "List" else a.
    tr:hohmann(ta).
    next().
  }).

  seq:add({
    parameter b, a, s.
    gear on.
    descent:suicide_burn(3000).
    if stage:number >= 2 {
      lock throttle to 0. wait 0.1. stage. wait 0.1.
    }
    descent:suicide_burn(50).
    descent:powered_landing().
    next().
  }).

  // allow kerbal to plant flag, etc. then get back in.
  seq:add({
    parameter b, a, s.
    if s = true or crewCount = 0 {
      print "no eva, skipping #1".
      wait 2.
      next().
    } else {
      // jump to next seq when first person gets out
      if ship:crew():length = (crewCount - 1) next().
    }
    wait 0.2.
  }).
  seq:add({
    parameter b, a, s.
    if s = true or crewCount = 0 {
      print "no eva, skipping #2".
      wait 2.
      next().
    } else {
      // take off when we have full crew back
      if ship:crew():length = crewCount next().
    }
    wait 0.2.
  }).

  seq:add({
    parameter b, a, s.

    // get into orbit
    lock steering to heading(90, 90).
    lock throttle to 1.
    wait 2.
    lock steering to heading(90, 45).
    wait until apoapsis > a.
    lock throttle to 0.
    gear off.

    // circularize at apo as we just took off
    tr:circ(20, false).

    // run transfer to Kerbin - generic height, we will adjust to true target later
    local bms is addons:astrogator:calculateBurns(Kerbin).
    tr:seek_SOI(Kerbin, a, bms[0]:atTime, 0, 20, bms).
    tr:exec(true, 20).
    next().
  }).

  seq:add({
    parameter b, a, s.
    local transition_time is time:seconds + eta:transition.
    warpto(transition_time).
    wait until time:seconds >= transition_time.
    next().
  }).

  seq:add({
    parameter b, a, s.
    if body = Kerbin {
      wait 10.
      tr:seek(fr(time:seconds + 120), fr(0), fr(0), 0, 20, list(), { parameter mnv. return -abs(mnv:orbit:periapsis - TGT_RETALT). }).
      tr:exec(true, 20).
      next().
    } else {
      wait 0.5.
    }
  }).

  seq:add({
    parameter b, a, s.
    if ship:altitude < RENT_BURNALT * 10 {
      set warp to 0. wait 1. next().
    } else {
      if not warping { set warping to true. set warp to 5. }
      wait 0.1.
    }
  }).

  seq:add({
    parameter b, a, s.
    if ship:altitude < RENT_BURNALT {
      ag10 off.
      lock steering to retrograde. wait 5. lock throttle to 1.
      wait until ship:maxthrust < 1.
      lock throttle to 0. stage. wait 1. lock steering to srfretrograde.
      next().
    } else wait 0.5.
  }).

  seq:add({
    parameter b, a, s.
    if (ship:status = "Landed" or ship:status = "Splashed") next(). else wait 0.5.
  }).

}).

export(m).