{
  local INF is 2^64.
  local tf is lex("exec", exec@, "freeze", freeze@, "seek_SOI", seek_SOI@, "seek", seek@).
  local dvlib is improot("lib/deltav").

  function exec {
    parameter wrp is 0, n is nextnode, v is n:burnvector, stT is time:seconds + n:eta - mnv_time(v:mag)[0].
    lock steering to n:burnvector. if wrp warpto(stT - 30). wait until time:seconds >= stT.
    local st is 0. local t is 0. lock throttle to t.
    until vdot(n:burnvector, v) < 0 or (st and t <= 0.002) {
      set st to 1. if maxthrust < 0.1 {
        stage. wait 0.1.
        if maxthrust < 0.1 { for part in ship:parts { for r in part:resources set r:enabled to true. } wait 0.1. }
      }
      set t to min(mnv_time(n:burnvector:mag)[0], 1). wait 0.1.
    }
    lock throttle to 0. unlock steering. remove nextnode. wait 0.
  }

  function seek {
    parameter t, r, n, p, fitFn, d is list(t, r, n, p), fit is orbFit(fitFn@).
    set d to optmz(d, fit, 5).
    set d to optmz(d, fit, 1).
    set d to optmz(d, fit, 0.05).
    fit(d). wait 0. return d.
  }

  function emptyCond { parameter mnv. return 0. }

  function seek_SOI {
    parameter tBody, tPeri, t is time:seconds + 600, p is 500, condFn is emptyCond@.
    local d is seek(t, 0, 0, p, {
      parameter mnv. if (mnv:orbit:eta:apoapsis > INF) { return -INF. }
      local cfv is condFn(mnv).
      if tfTo(mnv:orbit, tBody) return 1.
      return -closestApp(tBody, time:seconds + mnv:eta, time:seconds + mnv:eta + mnv:orbit:period) + cfv.
    }).
    return seek(d[0], d[1], d[2], d[3], {
      parameter mnv. if not tfTo(mnv:orbit, tBody) return -INF.
      return -abs(mnv:orbit:nextpatch:periapsis - tPeri).
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
    parameter dV.
    return dvlib:burn(dV).
  }

  function orbFit {
    parameter fitFn.
    return {
      parameter d. until not hasnode { remove nextnode. wait 0. }
      local new_node is node(unfr(d[0]), unfr(d[1]), unfr(d[2]), unfr(d[3])).
      add new_node. wait 0.
      return fitFn(new_node).
    }.
  }

  function optmz {
    parameter d, fitFn, sz, wng is list(fitFn(d), d), imp is best_nbr(wng, fitFn, sz).
    until imp[0] <= wng[0] { set wng to imp. set imp to best_nbr(wng, fitFn, sz). }
    return wng[1].
  }

  function best_nbr {
    parameter best, fitFn, sz.
    for n in ngbrs(best[1], sz) { local sc is fitFn(n). if sc > best[0] set best to list(sc, n). }
    return best.
  }

  function ngbrs {
    parameter dt, sz, rs is list().
    for j in range(0, dt:length) if not fr(dt[j]) { local i is dt:copy. local d is dt:copy. set i[j] to i[j] + sz. set d[j] to d[j] - sz. rs:add(i). rs:add(d).}
    return rs.
  }

  function freeze { parameter n. return lex("fr", n). }
  function fr { parameter v. return (v+""):indexof("fr") <> -1. }
  function unfr { parameter v. if fr(v) return v["fr"]. else return v. }
  export(tf).
}