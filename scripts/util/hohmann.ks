if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/").
runpath("1:/knu.ks").
local tr is import("lib/transfer").
local fr is tr:freeze.

local f is {
  parameter b, alt, t_wrp, stp.
  local should_wait is 0.
  if body <> b and eta:transition > 60 { warpto(time:seconds + eta:transition). set should_wait to 1. }
  wait until body = b.
  if should_wait wait 5.
  if orbit:eccentricity >= 1 tr:circ_per(stp, 20).
  tr:hohmann(alt, t_wrp, stp).
}.

parameter b, alt, t_wrp is 40, stp is 30.
f(b, alt, t_wrp, stp).