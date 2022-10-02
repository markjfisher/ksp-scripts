if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/").
runpath("1:/knu.ks").
local tr is import("lib/transfer").
local dvlib is improot("lib/deltav").

local f1 is {
  local bm is addons:astrogator:calculateBurns(Mun).
  print "dv: " + bm[0]:totalDV.
  print " t: " + bm[0].atTime.
//  tr:seek_SOI(Minmus, 30000, bm[0]:atTime, bm[0]:totalDV, 50, {
//    parameter mnv.
//    // try to make it close to the estimated dv, so it doesn't localise over pe but with high dv earlier in search.
//    return -abs(2000 * (mnv:deltav:mag - dv)).
//  }).
  tr:seek_SOI(Minmus, 30000, t, dv, 100).
}.

f1().