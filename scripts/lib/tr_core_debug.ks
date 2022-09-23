{
  local core is lex("ex_t", ex_t@).
  local o is import("lib/orbit").

  function drawSegment {
    parameter t1, t2, b.
    local t1p is positionAt(ship, t1).
    local t2p is positionAt(ship, t2).

    set arrow1 to vecdraw(
      body:position,
      t1p - body:position,
      red, "s", 1, true, 0.2, false, true
    ).

    set arrow2 to vecdraw(
      body:position,
      t2p - body:position,
      blue, "e", 1, true, 0.2, false, true
    ).

    set arrowT to vecdraw(
      b:position,
      body:position - b:position,
      yellow, "t", 1, true, 0.2, false, true
    ).
  }

  function ex_t { // calc exit time for a transfer to body b.
    parameter a, b, mP is 1. // target angle, target body, max periods

    local nseg is 13.
    local tSeg is orbit:period / nseg.
    local segAng is 360 / nseg.
    local sT is time:seconds + 60. local eT is sT + tSeg.
    local maxT is sT + orbit:period * mP.
    local foundSeg is false. local needFix is false.
    print "looking for " + a + ", segAng: " + segAng.
    until foundSeg or sT >= maxT {
      print "b, sT, eT: " + b + ", " + ship + ", " + ship:body + ", " + sT + ", " + eT.
      local sA is o:ang(b, sT). local eA is o:ang(b, eT).
      print "sA: " + round(sA, 3) + ", eA: " + round(eA, 3).

      drawSegment(sT, eT, b).

      local x1 is true. // (a > segAng and a < (360 - segAng)).
      local x2 is (eA >= a and sA <= a and sA < eA).
      local x is x1 and x2.
      print "x: " + x + ", (x1: " + x1 + ", x2: " + x2 + ")".
      if x {
        set foundSeg to true.
      }
      if (a <= segAng or a >= (360 - segAng)) and (eA < sA) {
        print "special check #1".
        local fa is choose a if a < segAng else a - 360.
        local negSA is sA - 360.
        if fa >= negSA and fa <= eA {
          set needFix to true. set foundSeg to true.
        }
      }
      if not foundSeg {
        print "nope".
        set sT to eT. set eT to eT + tSeg.
      }
    }

    if not foundSeg {
      print "No segment for angle " + a.
      return 0.
    }

    print "core: a: " + a + ", needFix: " + needFix.
    set a to choose a - 360 if needFix else a.
    local mT is (sT + eT) / 2.
    until (eT - sT < 0.1) {
      local aS is o:ang(b, sT).
      local aM is o:ang(b, mT).
      local aE is o:ang(b, eT).
      print "   sT, mT, eT: " + round(sT, 3) + ", " + round(mT, 3) + ", " + round(eT, 3).
      print "#1 aS, aM, aE: " + round(aS, 3) + ", " + round(aM, 3) + ", " + round(aE, 3).
      set aS to choose aS - 360 if needFix else aS.
      set aM to choose aM - 360 if needFix else aM.
      print "#2 aS, aM, aE: " + round(aS, 3) + ", " + round(aM, 3) + ", " + round(aE, 3).
      if (aE >= a and aM <= a) set sT to mT. else set eT to mT.
      set mT to (sT + eT) / 2.
      print "mT: " + mT.
    }
    clearvecdraws().
    return mT.
  }

  export(core).
}