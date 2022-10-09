if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/").
runpath("1:/knu.ks").
local tr is import("lib/transfer").
local fr is tr:freeze.

local f is {
  parameter b, at_peri, stp.
  if orbit:eccentricity < 0.0001 return 0.
  local should_wait is false.
  if body <> b and eta:transition > 60 { warpto(time:seconds + eta:transition). set should_wait to true. }
  wait until body = b.
  if should_wait wait 5.
  if at_peri tr:circ_per(stp, 30). else tr:circ_apo(stp, 30).
}.

parameter b, at_peri is true, stp is 5.
f(b, at_peri, stp).