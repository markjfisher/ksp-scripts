{
  local INF is 2^64.
  local tf is lex("exec", exec@, "freeze", f@, "seek_SOI", seek_SOI@, "seek", seek@, "hohmann", hohmann@, "circ_apo", c_apo@, "circ_per", c_per@).
  local dvlib is improot("lib/deltav").

  function exec { parameter wrp is 0, t_wrp is 30. until not hasnode {e(wrp, t_wrp).}}

  function e {
    parameter wrp is 0, t_wrp is 30, n is nextnode, v is n:burnvector, stT is time:seconds + n:eta - mnv_time(v:mag)[0].
    lock steering to n:burnvector. if wrp warpto(stT - t_wrp). wait until time:seconds >= stT.
    local st is 0. local t is 0. lock throttle to t.
    until vdot(n:burnvector, v) < 0 or (st and t <= 0.001) {
      set st to 1. if maxthrust < 0.1 {
        stage. wait 0.1.
        if maxthrust < 0.1 { for part in ship:parts { for r in part:resources set r:enabled to true. } wait 0.1. }
      }
      set t to min(mnv_time(n:burnvector:mag)[0], 1). wait 0.1.
    }
    lock throttle to 0. unlock steering. remove nextnode. wait 0.
  }

  function noFit { parameter mnv. return 0. }

  function seek {
    parameter t, r, n, p, stp is 50, bms is list(), fitFn is noFit@, d is list(t, r, n, p, bms), fit is orbFit(fitFn@).
    local steps is list(100, 50, 20, 5, 2, 0.5, 0.05). local sI is steps:iterator.
    until not sI:next {
      if sI:value <= stp set d to optmz(d, fit, sI:value).
    }
    fit(d). wait 0. return d.
  }


  function seek_SOI {
    parameter tBody, tPeri, t is time:seconds + 400, p is 200, stp is 50, bms is list(), xFit is noFit@.
    until not hasnode { remove nextnode. wait 0. }
    local u is 0.
    for bm in bms {
      // TODO, do we filter out already zero time burn models?
      if bm:atTime > 0 {
        add node(bm:atTime, bm:radial, bm:normal, bm:prograde).
        set u to bm:atTime.
      }
    }
    // take the latest of all the burn nodes + 60s as the starting time for a mnv node as it has to be after them.
    if u > 0 { set t to u + 60. set u to u + 60. }
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
        // everything inside the list boundaries is good, otherwise return difference to the middle of the boundaries
        if pe <= tPeri[1] and pe >= tPeri[0] return c. else return -abs(pe - (tPeri[1] - tPeri[0])/2) + c.
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

  function mnv_time {
    parameter dV. return dvlib:burn(dV).
  }

  function orbFit {
    parameter fitFn.
    return {
      parameter d.
      // first count the valid burn nodes
      local vb is 0. for bm in d[4] { if bm:atTime > 0 set vb to vb + 1. }

      // delete nodes at the vb index and after (but from the end)
      from { local x is allnodes:length - 1. } until x < vb step { set x to x-1. } do { remove allnodes[x]. }

      // now add our new test node to the end and fit it.
      local new_node is node(unfr(d[0]), unfr(d[1]), unfr(d[2]), unfr(d[3])). add new_node. wait 0.
      return fitFn(new_node).
    }.
  }

  function optmz {
    parameter d, fitFn, sz, wng is list(fitFn(d), d), imp is best_nbr(wng, fitFn, sz).
    until imp[0] <= wng[0] { set wng to imp. set imp to best_nbr(wng, fitFn, sz). }
    return wng[1].
  }

  function best_nbr {
    parameter best, fitFn, sz. for n in ngbrs(best[1], sz) { local sc is fitFn(n). if sc > best[0] set best to list(sc, n). }
    return best.
  }

  function ngbrs {
    parameter dt, sz, rs is list().
    for j in range(0, dt:length) {
      if not fr(dt[j]) {
        local i is dt:copy.
        local d is dt:copy.
        if i[j]:typename = "Scalar" {
          set i[j] to i[j] + sz.
          set d[j] to d[j] - sz.
        }.
        rs:add(i).
        rs:add(d).
      }
    }

    return rs.
  }

  function hohmann {
    parameter a, t_wrp is 40.

    // decide if this is a decreasing transfer or increasing.
    // if decreasing: at apo decrease peri, then at peri decrease apo.
    // if increasing: at peri increase apo, then at apo increace peri.
    // we will simply circularize at appropriate point for 2nd transfer
    local is_dec is a < orbit:apoapsis.

    // first transfer
    seek(f(choose (time:seconds + eta:apoapsis) if is_dec else (time:seconds + eta:periapsis)), f(0), f(0), 0, 5, list(), {
      parameter mnv.
      local h is choose mnv:orbit:periapsis if is_dec else mnv:orbit:apoapsis.
      return -abs(h - a).
    }).
    exec(true, t_wrp).
    circ(t_wrp, is_dec).

  }

  function c_apo {
    parameter t_wrp is 40.
    circ(t_wrp, false).
  }

  function c_per {
    parameter t_wrp is 40.
    circ(t_wrp, true).
  }

  function circ {
    parameter t_wrp, at_peri.
    seek(f(choose (time:seconds + eta:periapsis) if at_peri else (time:seconds + eta:apoapsis)), f(0), f(0), 0, 5, list(), {
      parameter mnv.
      return -mnv:orbit:eccentricity.
    }).
    exec(true, t_wrp).
  }

  // "freeze" - this wraps the value so it doesn't get changed when seeking
  function f { parameter n. return lex("fr", n). }
  // This is "frozen" function to check if a parameter is frozen or not
  function fr { parameter v. return (v+""):indexof("fr") <> -1. }
  // Unfreeze to unlock the value
  function unfr { parameter v. if fr(v) return v["fr"]. else return v. }
  export(tf).
}