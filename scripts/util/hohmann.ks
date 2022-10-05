if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/").
runpath("1:/knu.ks").
local tr is import("lib/transfer").
local fr is tr:freeze.

local f is {
  parameter b, alt, t_wrp.
  local should_wait is false.
  if body <> b and eta:transition > 60 { warpto(time:seconds + eta:transition). set should_wait to true. }
  wait until body = b.
  if should_wait wait 5.
  if orbit:eccentricity >= 1 tr:circ_per(20).
  tr:hohmann(alt, t_wrp).
}.

parameter b, alt, t_wrp is 40.
f(b, alt, t_wrp).