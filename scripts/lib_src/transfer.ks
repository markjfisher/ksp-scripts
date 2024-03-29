// Handles all transferring between bodies. Adapted from Cheers Kevin original work.
{
  local INF is 2^64.
  local tf is lex(
    "exec", exec@,
    "freeze", f@,
    "seek_SOI", seek_SOI@,
    "seek", seek@,
    "hohmann", hohmann@,
    "circ_apo", c_apo@,
    "circ_per", c_per@
  ).

  function exec { parameter wrp is 0, t_wrp is 30. until not hasnode {e(wrp, t_wrp). wait 0.}}

  function e {
    parameter wrp is 0, t_wrp is 30, n is nextnode, v1 is n:deltav, stT is time:seconds + n:eta - addons:ke:nodeHalfBurnTime.

    // check if it's worth doing this node at all
    if n:deltav:mag < 0.001 {
      remove nextnode.
      wait 0.
      return.
    }

    lock steering to n:deltav.
    if wrp warpto(stT - t_wrp).
    wait until time:seconds >= stT.

    // There is a small addition to time here of 0.005, just to ensure the final part of the burn happens with more thrust
    local t is 0. lock throttle to t.
    until vdot(n:deltav, v1) < 0 or (t > 0 and t <= 0.006) {
      if maxthrust < 0.1 {
        stage. wait 0.1.
        if maxthrust < 0.1 { for p in ship:parts { for r1 in p:resources set r1:enabled to true. } wait 0.1. }
      }
      set t to min(addons:ke:nodeHalfBurnTime + 0.005, 1).
      wait 0.01.
    }
    lock throttle to 0.
    unlock steering.
    remove nextnode.
    wait 0.
  }

  // A dummy function that returns 0 change for the maneuver.
  function noFit { parameter mnv. return 0. }

  function seek {
    parameter t, r1, n, p, stp is 30, bms is list(), fitFn is noFit@, d is list(t, r1, n, p, bms), fit is orbFit(fitFn@).
    // current step will be decreased until under some limit
    local cs is stp.
    until cs < 0.042 {
      set d to optmz(d, fit, cs).
      set cs to cs / 3.75.
    }
    fit(d). wait 0. return d.
  }

  function seek_SOI {
    parameter b, per, t, p, stp is 30, bms is list(), xFit is noFit@.

    local needs_soi is 1.
    local att is 0.

    until (not needs_soi) or (att > 5)  {
      SOI_loop(b, per, t, p, stp, bms, xFit).

      local an is allnodes.
      if not hasnode or not (an[an:length - 1]:orbit:hasnextpatch and an[an:length - 1]:orbit:nextpatch:body = b) {
        set att to att + 1.
        print "Attempt " + att + "; failed to get SOI to: " + b.
        // move around orbit and reloop, SOI_loop deletes nodes
        warpto(time:seconds + orbit:period - 10).
        set t to t + orbit:period.
      } else set needs_soi to 0.
    }
    // also acts as return flag
    return not needs_soi.
  }

  function SOI_loop {
    parameter tBody, tPeri, t, p, stp, bms, xFit.
    until not hasnode { remove nextnode. wait 0. }
    local u is 0.
    for bm in bms {
      // TODO, do we filter out already zero time burn models?
      if bm:atTime > 0 {
        add node(bm:atTime, bm:radial, bm:normal, bm:prograde).
        set u to bm:atTime.
      } else print "got a time 0 burnModel in " + bm.
    }
    // take the latest of all the burn nodes + 60s as the starting time for a mnv node as it has to be after them.
    if u > 0 { set t to u + 60. set u to t. }
    local d is seek(t, 0, 0, p, stp, bms, {
      parameter mnv.
      if mnv:time < u return -INF.
      if tfTo(mnv:orbit, tBody) return 1.
      local per is choose mnv:orbit:eta:transition if mnv:orbit:eta:apoapsis > INF else mnv:orbit:period.
      return -closestApp(tBody, time:seconds + mnv:eta, time:seconds + mnv:eta + per) + xFit(mnv).
    }).
    return seek(d[0], d[1], d[2], d[3], stp, bms, {
      parameter mnv.
      if mnv:time < u return -INF.
      if not tfTo(mnv:orbit, tBody) return -INF.
      local pe is mnv:orbit:nextpatch:periapsis.
      local c is xFit(mnv).
      if tPeri:typename = "List" {
        // everything inside the list boundaries is good, otherwise return difference to the closest boundary
        if pe <= tPeri[1] and pe >= tPeri[0] return c. else {
          if pe >= tPeri[1] return tPeri[1] - pe + c.
          return pe - tPeri[0] + c.
        }
      }
      // otherwise, just take diff from the peri specified
      return -abs(mnv:orbit:nextpatch:periapsis - tPeri) + c.
    }).
  }

  function tfTo { parameter tOrb, tBody. return (tOrb:hasnextpatch and tOrb:nextpatch:body = tBody). }

  function closestApp {
    parameter b, sT, eT.
    local stSlope is slopeAt(b, sT). local midT is (sT + eT) / 2. local midS is slopeAt(b, midT).
    until (eT - sT < 0.1) or midS < 0.1 {
      if (midS * stSlope) > 0 set sT to midT. else set eT to midT.
      set midT to (sT + eT) / 2. set midS to slopeAt(b, midT).
    }
    return sepAt(b, midT).
  }

  function slopeAt { parameter b, t. return (sepAt(b, t + 1) - sepAt(b, t - 1)) / 2. }
  function sepAt { parameter b, t. return (positionat(ship, t) - positionat(b, t)):mag. }

  function orbFit {
    parameter fitFn.
    return {
      parameter d.
      // first count the valid burn nodes
      local vb is 0. for bm in d[4] { if bm:atTime > 0 set vb to vb + 1. }

      // delete nodes at the vb index and after (but from the end)
      from { local x is allnodes:length - 1. } until x < vb step { set x to x-1. } do { remove allnodes[x]. }

      // now add our new test node to the end and fit it.
      local new_node is node(unf(d[0]), unf(d[1]), unf(d[2]), unf(d[3])). add new_node. wait 0.
      return fitFn(new_node).
    }.
  }

  function optmz {
    parameter d, fitFn, sz, wng is list(fitFn(d), d), imp is best_nbr(wng, fitFn, sz).
    // step count to check if we have gone too many loops with almost no improvement
    local sc is 0.
    // score diff, to catch drilling too close onto improvement
    local sd is 0.
    // quit looking is flag set if we've iterate too long
    local ql is 0.
    until (imp[0] <= wng[0]) or ql {
      set wng to imp.
      set imp to best_nbr(wng, fitFn, sz).
      set sc to sc + 1.
      set sd to abs(imp[0] - wng[0]).
      set ql to sc > 40 and sd < 0.0001.
    }
    return wng[1].
  }

  function best_nbr {
    parameter best, fitFn, sz.
    for n in ngbrs(best[1], sz) {
      local sc is fitFn(n).
      if sc > best[0] set best to list(sc, n).
    }
    return best.
  }

  function ngbrs {
    parameter dt, sz, rs is list().
    for j in range(0, dt:length) {
      if not fr(dt[j]) {
        local i is dt:copy.
        local d is dt:copy.
        if i[j]:typename = "Scalar" {
          // give up to 2.5% random around step size.
          set i[j] to i[j] + sz + (random() - 0.5) / 20 * sz.
          set d[j] to d[j] - sz + (random() - 0.5) / 20 * sz.
        }.
        rs:add(i).
        rs:add(d).
      }
    }

    return rs.
  }

  function hohmann {
    parameter a, t_wrp is 40, stp is 30.

    // decide if this is a decreasing transfer or increasing.
    // if decreasing: at apo decrease peri, then at peri decrease apo.
    // if increasing: at peri increase apo, then at apo increace peri.
    // we will simply circularize at appropriate point for 2nd transfer
    local is_dec is a < orbit:apoapsis.

    // first transfer
    seek(f(choose (time:seconds + eta:apoapsis) if is_dec else (time:seconds + eta:periapsis)), f(0), f(0), 0, stp, list(), {
      parameter mnv.
      local h is choose mnv:orbit:periapsis if is_dec else mnv:orbit:apoapsis.
      return -abs(h - a).
    }).
    exec(true, t_wrp).
    // now circularize
    circ(stp, t_wrp, is_dec, false).

  }

  function c_apo {
    parameter stp is 30, t_wrp is 40, isLaunch is false.
    circ(stp, t_wrp, false, isLaunch).
  }

  function c_per {
    parameter stp is 30, t_wrp is 40.
    circ(stp, t_wrp, true, false).
  }

  function circ {
    parameter stp, t_wrp, at_peri, isLaunch is false.
    // This assumes you have enough time to perform the full burn, and may lead to a node in the past if the seek takes too long and the ap/pe is close.
    // difficult to wait until another orbit as you may not have one, e.g. launching.
    // If this happens, the ship needs more initial thrust to give it time before reaching its peak to calculate the mnv.

    local iP is 0.
    // isLaunch allows us to calculate an initial prograde value by subracting the current horizontal speed from the perfect speed at the chosen ap
    // it's all prograde at apoapsis, so subtracting the current horizontal speed will give a good estimate (I think) for dv start from.
    if isLaunch {
      local h is body:radius + apoapsis.
      local sAtAp is addons:astrogator:speedAtApoapsis(body, h, h).
      print "speedAtApoapsis: " + sAtAp.
      print "horiz speed: " + ship:groundSpeed.
      // until i work out why there's a difference in theoretical vs groundspeed, just knock 200 off. maybe the bodies rotational speed is diff
      set iP to sAtAp - ship:groundSpeed - 200.
      print "initial pro for launch: " + iP.
    }
    seek(f(choose (time:seconds + eta:periapsis) if at_peri else (time:seconds + eta:apoapsis)), f(0), f(0), iP, stp, list(), {
      parameter mnv.
      return -mnv:orbit:eccentricity.
    }).
    exec(true, t_wrp).
  }

  // "freeze" - this wraps the value so it doesn't get changed when seeking
  function f { parameter n. return lex("fr", n). }
  // This is "frozen" function to check if a parameter is frozen or not
  function fr { parameter v1. return (v1+""):indexof("fr") <> -1. }
  // Unfreeze to unlock the value
  function unf { parameter v1. if fr(v1) return v1["fr"]. else return v1. }
  export(tf).
}