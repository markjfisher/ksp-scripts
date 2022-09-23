if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/").
runpath("1:/knu.ks").
local tr_km is import("lib/tr_kerbin_mun").
local tr_mk is import("lib/tr_mun_kerbin").
local tr is import("lib/transfer").
local dv is improot("lib/deltav").

local f1 is {
  local trd is tr_mk:calc(). local dv is trd[0]. local t is choose time:seconds + 360 if trd[1] = 0 else trd[1].
  print "dv: " + dv.
  print " t: " + t.
  tr:seek_SOI(Kerbin, 35000, t, dv, 50, {
    parameter mnv.
    // try to make it close to the estimated dv, so it doesn't localise over pe but with high dv earlier in search.
    return -abs(2000 * (mnv:deltav:mag - dv)).
  }).
  // tr:seek_SOI(Kerbin, 35000, t, dv, 50).
}.

f1().