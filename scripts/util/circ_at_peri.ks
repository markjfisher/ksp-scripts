if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/").
runpath("1:/knu.ks").
local tr is import("lib/transfer").
local fr is tr:freeze.

local f is {
  parameter b.
  if body <> b and eta:transition > 60 { warpto(time:seconds + eta:transition). }
  wait until body = b.
  wait 5.
  set sPeri to addons:astrogator:speedAtPeriapsis(Mun, orbit:periapsis, orbit:periapsis).
  print "should be going " + sPeri.
  tr:seek(fr(time:seconds + eta:periapsis), fr(0), fr(0), 0, { parameter mnv. return - mnv:orbit:eccentricity. }).
  tr:exec(true, 20).
}.

parameter b.
f(b).