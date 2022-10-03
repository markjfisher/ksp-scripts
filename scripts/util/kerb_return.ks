if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/").
runpath("1:/knu.ks").
local tr is import("lib/transfer").
local fr is tr:freeze.

local TGT_RETALT is 35000.
local RENT_BURNALT is 100000.

// assumes in orbit somewhere, wanting to head back to kerbin.
local f is {
  local bm is addons:astrogator:calculateBurns(Kerbin).
  set dv to bm[0]:totalDV.
  set t to bm[0]:atTime.
  tr:seek_SOI(Kerbin, TGT_RETALT, t, dv, 20).
  tr:exec(true).

  local transition_time is time:seconds + eta:transition.
  warpto(transition_time).
  wait until time:seconds >= transition_time.

  wait until body = Kerbin.
  wait 5.

  tr:seek(fr(time:seconds + 120), fr(0), fr(0), 0, { parameter mnv. return -abs(mnv:orbit:periapsis - TGT_RETALT). }).
  tr:exec(true, 20).

  set warp to 5.
  wait until ship:altitude < RENT_BURNALT * 8.
  set warp to 0. wait 1.

  wait until ship:altitude < RENT_BURNALT.

  ag10 off.
  lock steering to retrograde. wait 5. lock throttle to 1.
  wait until (ship:maxthrust < 1 or ship:orbit:periapsis < 0).
  lock throttle to 0. stage. wait 1. lock steering to srfretrograde.

  wait until ship:status = "Landed" or ship:status = "Splashed".

  print "finished return.".

}.

f().