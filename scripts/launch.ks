{
  // Launch ship from Kerbal and get circular orbit.
  //
  // Use this from the root volume with:
  // improot("launch.ks"):exec(inc, apo, [verbose = false], [circ = true], [inverted = false]).
  // so that no disk space is used.

  // In missions:
  // local launch is improot("launch").
  // local m is mission({ parameter seq, ev, next.
  //   seq:add({
  //      parameter b, a, pro.
  //      if ship:status = "prelaunch" launch:exec(0, 82).
  //      next().
  //    }).
  //    // etc.
  // }).
  // export(m).

  // REQUIREMENTS
  // The ship must have 2 initial stages (counting from last backwards), 1 for the engines, 2nd for the clamps.
  // The engines will start, and 1s later clamps released to ensure an initial thrust available.
  // It does not auto-stage when fuel runs out, you need to add a sensor to the tank for that.

  // ACTION GROUPS
  // AG5  Fairings
  // AG10 Autodeploy for anything custom (done at deployAlt height)

  local l_version is "v1.0.4".

  local tr is improot("lib/transfer").

  local launch is lex("exec", exec@).

  local thrustSetting is 1.
  local thrustLimiter is 1.
  local deployed is false.
  local proLocked is false.
  local thrustLimited is false.
  local upperLimited is false.
  local aborted is false.
  local fairingStaged is false.
  local vPitch is 90.
  local vHeading is 0.
  local voice is getVoice(0).
  local voiceTickNote is note(480, 0.1).
  local voiceTakeOffNote is note(720, 0.5).

  // Tunables, but considering them constant.
  local pitchStartingAlt is 250.
  local halfPitchedAlt is 12000.
  local tLimitAlt is 20000.
  local thrustAdj is 1.1.
  local finalThrustAdj is 0.9.
  local lockAlt is 40000.
  local fairingAlt is 50000.
  local deployAlt is 71000.

  // params to locals
  local desiredInclination is 0.
  local desiredApoapsis is 0.
  local shouldCirc is true.
  local verbose is true.
  local flightAt is false.
  local desiredHeading is 0.

  function exec {
      parameter inc,
      apo,
      pHeading is 90,
      logging is false,
      circ is true,
      inverted is false. // pass in true to invert flight which just rotates the ship so that East is UP on navball

    print "launch: " + l_version.
    set desiredInclination to inc.
    set desiredApoapsis to apo.
    set desiredHeading to pHeading.
    set shouldCirc to circ.
    set verbose to logging.
    set flightAt to inverted.

    wait 1.
    if verbose clearscreen.
    setAbortTrigger().
    countDown().
    if not aborted { set oldThrust to availablethrust. pitchManuever(). }
    if not aborted { gravityTurn(). }
    if not aborted { meco(). if circ circularize(). }
    return aborted.
  }

  function setAbortTrigger {
    on abort {
      if not aborted {
        lock throttle to 0. abort on.
        if verbose { print " ". print "Abort triggered manually". }
        set aborted to true.
      }
      return aborted. // doesn't work when coming out of "on"
    }
  }

  function countdown {
    sas off.
    if verbose {
      print "5". voice:play(voiceTickNote). wait 1.
      print "4". voice:play(voiceTickNote). wait 1.
      print "3". voice:play(voiceTickNote). wait 0.5.
    }
    lock steering to up + r(0, 0, 180).
    if verbose { print "locking attitude control". wait 0.5. }

    if verbose { print "2". voice:play(voiceTickNote). wait 0.5. }
    lock throttle to 1. wait 0.5.
    if verbose {
      print "throttle to full".
      print "1". voice:play(voiceTickNote).
      print "ignition".
    }
    stage.

    if (ship:availablethrust() < 1.15 * mass * constant:g0) {
      print " ". print "subnominal thrust detected".
      print "attempting shutdown".
      lock throttle to 0.
    } else {
      wait 1. stage.
      if verbose { print "launch". voice:play(voicetakeoffnote). wait 0.1. }
    }

    wait 2.
  }

  function pitchManuever {
    lock vpitch to 90 - vang(up:forevector, facing:forevector).
    lock vheading to mod(360 - latlng(90, 0):bearing, 360).
    until (altitude > pitchStartingAlt) {
      if abs(vpitch - myPitch()) > 10 and not aborted { autoAbort(). break. }
      wait 0.1.
    }
    if verbose { print " ". print "starting pitching maneuver". }
    set initialHeading to myHeading().
    set initialRoll to myRoll().
    lock steering to heading(initialHeading, myPitch())+ r(0, 0, initialRoll).
    wait 2.
  }

  function myPitch {
    return 90 * halfPitchedAlt / (altitude + halfPitchedAlt).
  }

  function myHeading {
    set roughHeading to desiredHeading - desiredInclination.
    if (roughHeading < 0) { set roughHeading to 360 + roughHeading. }
    set triAng to abs(90 - roughHeading).

    // vH calculation assumes orbital speed of 1320 m/s when vessel locks to prograde
    set vH to sqrt(1774800 - 475200*cos(triAng)).
    set correction to arcsin(180*sin(triAng) / vH).
    if (desiredInclination > 0) { set correction to -1*correction. }
    if ((roughHeading + correction) < 0) { return roughHeading + correction + 360. }
    else { return roughHeading + correction. }
  }

  function myRoll {
    if (flightAt = true) { return 270 - myHeading(). } else return 360 - myHeading().
  }

  function gravityTurn {
    local waitPeriod is 0.1.
    until (apoapsis > desiredApoapsis * 1000) {
      if (altitude > lockAlt) and not proLocked { lockToPrograde(). }
      if (altitude > tLimitAlt) and not thrustLimited { limitThrust(). }
      if (shipTWR() < thrustAdj - 0.1) and thrustLimited and not upperLimited { limitThrust(). }
      if (altitude > deployAlt) and not deployed { autoDeploy(). }
      if (altitude > fairingAlt) and not fairingStaged { autoFairing(). }
      if (altitude > desiredApoapsis * 1000 - 2000) set waitPeriod to 0.05.
      if desiredInclination < 80 or desiredInclination > 100 {
        if (altitude < lockAlt) and not aborted {
          if abs(vPitch - myPitch()) > 10 or abs(vHeading - myHeading()) > 10 { 
            print "pitch / heading out".
            print "     vPitch: " + vPitch.
            print "  myPitch(): " + myPitch().
            print "   vHeading: " + vHeading.
            print "myHeading(): " + myHeading().
            print "       abs1: " + abs(vPitch - myPitch()).
            print "       abs2: " + abs(vHeading - myHeading()).
            autoAbort(). break.
          }
        } else {
          if vAng(facing:forevector, prograde:forevector) > 15 and not aborted {
            print "forevectors out".
            print "    facing:forevector: " + facing:forevector.
            print "  prograde:forevector: " + prograde:forevector.
            print "                 vang: " + vAng(facing:forevector, prograde:forevector).
            autoAbort(). break.
          }
        }
      }
    }
    wait waitPeriod.
  }

  function autoAbort {
    voice:play(voiceTickNote).
    lock throttle to 0.
    if altitude < tLimitAlt { abort on. }
    print " ". print "Attitude control loss detected, aborting".
    set aborted to true.
  }

  function autoFairing {
    local fairing is false.
    local partlist is 0.
    list parts in partlist.
    if verbose { print "autoFairing triggered". }
    for part in partlist {
      if (part:NAME = "fairingSize1" or
          part:NAME = "fairingSize1p5" or
          part:NAME = "fairingSize2" or
          part:NAME = "fairingSize3" or
          part:NAME = "fairingSize4" or
          part:NAME = "restock-fairing-base-0625-1" or
          part:NAME = "restock-fairing-base-1875-1" or
          part:NAME = "KzProcFairingSide1" or
          part:NAME = "MainSailorFairing001" or
          part:NAME = "MainSailorFairing001BK" or
          part:NAME = "MainSailorFairing001SyzWht" or
          part:NAME = "MainSailorFairingConicBlk" or
          part:NAME = "MainSailorFairingConicGamma" or
          part:NAME = "MainSailorFairingConicWht" or
          part:NAME = "MainSailorFairingEggBlk" or
          part:NAME = "MainSailorFairingEggGamma" or
          part:NAME = "MainSailorFairingEggWht" or
          part:NAME = "FASAStrFairing3m4x"
      ) {
        set fairing to true.
        break.
      }
    }
    if fairing {
      if verbose { print " ". print "staging fairing.". }
      ag5 on.
    }
    set fairingstaged to true.
  }

  function autoDeploy {
    if verbose { print " ". print "Extending deployable equipment". }
    ag10 on.
    set deployed to true.
  }

  function lockToPrograde {
    if verbose print "locking to prograde".
    lock steering to prograde + r(0, 0, myRoll()).
    set proLocked to true.
  }

  function shipTWR {
    return availablethrust*thrustSetting / (mass * constant:g0).
  }

  function limitThrust {
    lock Fg to (body:mu / (body:radius + altitude)^2) * mass.

    if (availablethrust > 0) {
      if not thrustLimited {
        set thrustSetting to thrustAdj*Fg / (availablethrust + 0.001).
        if verbose { print " ". print "Adjusting TWR to " + thrustAdj. }
      } else {
        set thrustSetting to finalThrustAdj*Fg / (availablethrust + 0.001).
        if verbose { print "Adjusting TWR to " + finalThrustAdj. }
      }
      lock throttle to thrustSetting.
      if thrustLimited { set upperLimited to true. }
      set thrustLimited to true.
    } else {
      if verbose print "No available thrust in current stage, moving to next stage".
      stage.
      wait 0.1.
    }
  }

  function meco {
    lock THROTTLE to 0.
    if verbose { print " ". print "engine cut-off". }
    wait until altitude > lockAlt.
    if not proLocked { lockToPrograde(). }
    set warp to 6. // still in atmosphere, so will cap at 4 probably
    wait until altitude > deployAlt - 1000.
    set warp to 0.
    wait until altitude > deployAlt.
    if not deployed { autoDeploy(). }
  }

  function circularize {
    tr:circ_apo(10, 80, true).
    lock throttle to 0.
    lockToPrograde().
  }

  export(launch).
}