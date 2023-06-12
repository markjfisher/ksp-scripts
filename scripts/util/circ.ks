if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/").
runpath("1:/knu.ks").
local tr is import("lib/transfer").
local fr is tr:freeze.

// Circularise around body at periapsis point.
// Assumes you are heading into SOI of target body, or already in eliptical orbit around it.
// Rarely use this as the missions scripts usually put you in circ orbit, but this is useful for testing, or resetting after manual maneuveurs

// usage from console:
// runpath("0:/util/circ", Mun).

// Parameters:
//  b: Body, [REQUIRED] Target body you are heading towards already
// at_peri: boolean, [OPTIONAL] if true, will use periapsis, else apoapsis. Warning! If you are not already in eliptical orbit, there will be no apoapsis. default true.
// stp: number, [OPTIONAL] the initial step for the seeking algorithm. default 30

local f is {
  parameter b, at_peri, stp.
  if orbit:eccentricity < 0.0001 return 0.
  local should_wait is false.
  if body <> b and eta:transition > 60 { warpto(time:seconds + eta:transition). set should_wait to true. }
  wait until body = b.
  if should_wait wait 5.
  if at_peri tr:circ_per(stp, 30). else tr:circ_apo(stp, 30).
}.

parameter b, at_peri is true, stp is 30.
f(b, at_peri, stp).