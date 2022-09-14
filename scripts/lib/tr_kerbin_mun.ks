// provides estimated DV and start time for nodes transferring from kerbin to mun, target pe 30k
{
  local tr is lex("calc", calc@).
  local o is import("lib/orbit").
  function calc {
    local h is orbit:semimajoraxis - body:radius.
    local dv is choose low(h) if h <= 400000 else hi(h).
    local t is ex_t(h).
    return list(dv, t).
  }
  // got through test craft in orbit and best fit to data.
  function low { parameter h. return 915.2101071 - 8.46510532e-4 * h + 6.157517419e-10 * h * h. }
  function hi { parameter h. return 3742.0101 - 236.51475 * ln(h). }
  function ex_ang { parameter h. return 117.169072 - 5.632302405e-6 * h. }

  function ex_t {
    parameter h.
    // prograde only at moment
    // find the time when ship lags mun by good exit angle
    local a is ex_ang(h).
    // now we have the angle required, find when ship will be closest to that angle in its next orbit, starting in 60s
    local sT is time:seconds + 60. local eT is sT + orbit:period. local mT is (sT + eT) / 2.
    print "Start: target a = " + a + ", sT = " + sT + ", eT = " + eT.
    until (eT - sT < 0.1) {
      // what's the angle at start and mid, adjust sT/eT accordingly and repeat, closing in on best time to angle
      local aS is o:ang(body("mun"), sT).
      local aM is o:ang(body("mun"), mT).
      print "aS = " + aS + ", aM = " + aM.
      if (aS <= a and aM >= a) or (aS >= a and aM <= a) set eT to mT. else set sT to mT.
      set mT to (sT + eT) / 2.
      print "closing on: sT = " + sT + ", eT = " + eT.
    }
    return mT.
  }

  export(tr).
}