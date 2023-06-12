if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/").
runpath("1:/knu.ks").
local tr is import("lib/transfer").
local fr is tr:freeze.

// Perform hohmann transfer to get to a different altitude around target body.
// Note, you can be heading towards the body and don't already have to be in inclined orbit around it

// b = body
// a = altitude to circ at
// t_wrp = time before node to warp to (default 40s)
// stp = initial stepping value for estimating (default 30)


local f is {
  parameter b, a, t_wrp, stp.
  local should_wait is 0.
  if body <> b and eta:transition > 60 { warpto(time:seconds + eta:transition). set should_wait to 1. }
  wait until body = b.
  if should_wait wait 5.
  if orbit:eccentricity >= 1 tr:circ_per(stp, 20).
  tr:hohmann(a, t_wrp, stp).
}.

parameter b, a, t_wrp is 40, stp is 30.
f(b, a, t_wrp, stp).