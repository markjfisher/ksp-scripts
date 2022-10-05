if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/").
runpath("1:/knu.ks").
local tr is import("lib/transfer").
local fr is tr:freeze.

local f is {
  parameter b, at_peri.
  if orbit:eccentricity < 0.0001 return 0.
  local should_wait is false.
  if body <> b and eta:transition > 60 { warpto(time:seconds + eta:transition). set should_wait to true. }
  wait until body = b.
  if should_wait wait 5.
  tr:circ(20, at_peri).
}.

parameter b, at_peri is true.
f(b, at_peri).