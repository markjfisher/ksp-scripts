{
  local core is lex("ex_t", ex_t@).
  local o is import("lib/orbit").

  function defChk { parameter sT, eT, o. return true. }

  function ex_t { // calc exit time for a transfer to body b.
    parameter a, b, mP is 1, chk is defChk@. // target angle, target body, max periods, additional checker

    local nseg is 13.
    local tSeg is orbit:period / nseg.
    local segAng is 360 / nseg.
    local sT is time:seconds + 360. local eT is sT + tSeg.
    local maxT is sT + orbit:period * mP.
    local foundSeg is false. local needFix is false.
    until foundSeg or sT >= maxT {
      local sA is o:ang(b, sT). local eA is o:ang(b, eT).
      local x1 is true. // (a > segAng and a < (360 - segAng)). TODO: why don't I need this?
      local x2 is (eA >= a and sA <= a and sA < eA).
      local x is x1 and x2.
      if x { set foundSeg to true. }
      if (a <= segAng or a >= (360 - segAng)) and (eA < sA) {
        local fa is choose a if a < segAng else a - 360.
        local negSA is sA - 360.
        if fa >= negSA and fa <= eA { set needFix to true. set foundSeg to true. }
      }
      if foundSeg set foundSeg to chk(sT, eT, o).
      if not foundSeg { set sT to eT. set eT to eT + tSeg. }
    }

    if not foundSeg {
      print "No segment for angle " + a.
      return 0.
    }

    set a to choose a - 360 if needFix else a.
    local mT is (sT + eT) / 2.
    until (eT - sT < 0.1) {
      local aS is o:ang(b, sT). local aM is o:ang(b, mT). local aE is o:ang(b, eT).
      set aS to choose aS - 360 if needFix else aS.
      set aM to choose aM - 360 if needFix else aM.
      if (aE >= a and aM <= a) set sT to mT. else set eT to mT.
      set mT to (sT + eT) / 2.
    }
    return mT.
  }

  export(core).
}