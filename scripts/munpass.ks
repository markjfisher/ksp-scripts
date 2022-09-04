// Mun Flyby mission script

local transfer is import("transfer").
local mission is import("mission").
local launch is improot("launch.ks"). // too large for disk, but allowing this to be import from archive as we're in close proximity to mission control

local TARGET_ALTITUDE is 83000.
local TARGET_MUNAR_ALTITUDE is 20000.
local TARGET_RETURN_ALTITUDE is 30000.
local REENTRY_BURN_ALTITUDE is 100000.
local freeze is transfer["freeze"].

local munflyby_mission is mission({ parameter seq, ev, next.

  // **************************************
  seq:add({
    launch["exec"](0, TARGET_ALTITUDE / 1000, false).
    // force a stage now we are in circular orbit. better would be to be able to calculate the mnv_time
    // with all engines, inc ones not lit
    wait 1. stage. wait 1.
    next().
  }).

  // **************************************
  // Head to Mun
  seq:add({
    transfer["seek_SOI"](Mun, TARGET_MUNAR_ALTITUDE, time:seconds + 60).
    transfer["exec"](true).
    next().
  }).

  seq:add({
    if not ship:obt:hasnextpatch {
      local correction_time is time:seconds + (eta:apoapsis / 4).
      transfer["seek_SOI"](Mun, TARGET_MUNAR_ALTITUDE, freeze(correction_time)).
      transfer["exec"](true).
      wait 1.
    }
    next().
  }).

  seq:add({
    if body <> Mun and eta:transition > 60 {
      warpto(time:seconds + eta:transition).
    }
    if body = Mun next().
  }).

  // Do we need to wait until we've passed the periapsis here?
  seq:add({
    if body = Mun {
      wait 30.
      transfer["seek"](
        freeze(time:seconds + 120), freeze(0), freeze(0), 0,
          { parameter mnv. return -abs(mnv:orbit:periapsis - TARGET_MUNAR_ALTITUDE). }).
      transfer["exec"](true).
      next().
    }
  }).

  // **************************************
  // Return to Kerbin
  seq:add({
    transfer["seek_SOI"](Kerbin, TARGET_RETURN_ALTITUDE).
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
      wait 30.
      transfer["seek"](
        freeze(time:seconds + 120), freeze(0), freeze(0), 0,
          { parameter mnv. return -abs(mnv:orbit:periapsis -
            TARGET_RETURN_ALTITUDE). }).
      transfer["exec"](true).
      next().
    }
  }).

  seq:add({
    if alt:radar < REENTRY_BURN_ALTITUDE * 4 {
        set warp to 0.
      next().
    } else {
      set warp to 6.
    }
  }).

  seq:add({
    if ship:altitude < REENTRY_BURN_ALTITUDE {
      lock steering to retrograde.
      lock throttle to 1.
      wait until ship:maxthrust < 1.
      lock throttle to 0.
      stage. wait 0.
      lock steering to srfretrograde.
      next().
    }
  }).

  seq:add({ if ship:status = "Landed" next(). }).

}).

export(munflyby_mission).