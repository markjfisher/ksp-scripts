local transfer is import("transfer").
local mission is import("mission").
local launch is improot("launch").

local TARGET_ALTITUDE is 83000.
local TARGET_MUNAR_ALTITUDE is 300000.
local TARGET_RETURN_ALTITUDE is 35000.
local REENTRY_BURN_ALTITUDE is 100000.
local freeze is transfer["freeze"].
local warping is false.
local aborted is false.
local havePrintedAbortMessage is false.

local mun_cr_mission is mission({ parameter seq, ev, next.
  seq:add({
    if not aborted { set aborted to launch["exec"](0, TARGET_ALTITUDE / 1000, true). }
    if not aborted { wait 1. stage. wait 1. next(). } else {
      if not havePrintedAbortMessage { print "aborted launch. press ctrl-c to get console back". set havePrintedAbortMessage to true. }
    }
    wait 5.
  }).

  seq:add({
    transfer["seek_SOI"](Mun, TARGET_MUNAR_ALTITUDE, time:seconds + 360, 860).
    transfer["exec"](true).
    next().
  }).

  seq:add({
    if body <> Mun and eta:transition > 60 { warpto(time:seconds + eta:transition). }
    if body = Mun next().
  }).

  seq:add({
    if body = Mun {
      wait 20. transfer["seek"](
        freeze(time:seconds + 120), freeze(0), freeze(0), 0,
        { parameter mnv. return -abs(mnv:orbit:periapsis - TARGET_MUNAR_ALTITUDE). }).
      transfer["exec"](true).
      next().
    }
    wait 0.1.
  }).

  seq:add({
    transfer["seek"](
      freeze(time:seconds + eta:periapsis), freeze(0), freeze(0), 0,
      { parameter mnv. return - abs(0.5 - mnv:orbit:eccentricity). }).
    transfer["exec"](true).
    next().
  }).

  seq:add({
    wait 10.
    local betweenTime is time:seconds + (eta:periapsis * 0.77). // roughly good exit
    transfer["seek_SOI"](Kerbin, TARGET_RETURN_ALTITUDE, betweenTime, 300).
    transfer["exec"](true).
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
      wait 30. transfer["seek"](
        freeze(time:seconds + 120), freeze(0), freeze(0), 0,
        { parameter mnv. return -abs(mnv:orbit:periapsis - TARGET_RETURN_ALTITUDE). }).
      transfer["exec"](true).
      next().
    }
  }).

  seq:add({
    if ship:altitude < REENTRY_BURN_ALTITUDE * 10 {
      set warp to 0. wait 1.
      next().
    } else {
      if not warping { set warping to true. set warp to 5. }
      wait 0.1.
    }
  }).

  seq:add({
    if ship:altitude < REENTRY_BURN_ALTITUDE {
      ag10 off.
      lock steering to retrograde.
      lock throttle to 1.
      wait until ship:maxthrust < 1.
      lock throttle to 0.
      stage. wait 1.
      lock steering to srfretrograde.
      next().
    }
  }).

  seq:add({ if ship:status = "Landed" next(). }).

}).

export(mun_cr_mission).