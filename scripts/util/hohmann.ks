if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/").
runpath("1:/knu.ks").
local tr is import("lib/transfer").
local fr is tr:freeze.

local f is {
  parameter b, alt.
  if body <> b and eta:transition > 60 { warpto(time:seconds + eta:transition). }
  wait until body = b.
  wait 5.
  if orbit:eccentricity >= 1 tr:circ(20).
  tr:hohmann(alt).
}.

parameter b, alt.
f(b, alt).