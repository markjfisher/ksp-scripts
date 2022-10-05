if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/").
runpath("1:/knu.ks").
local tr is import("lib/transfer").
local fr is tr:freeze.

local f is {
  parameter b, at_peri.
  if body <> b and eta:transition > 60 { warpto(time:seconds + eta:transition). }
  wait until body = b.
  wait 5.
  tr:circ(20, at_peri).
}.

parameter b, at_peri is true.
f(b, at_peri).