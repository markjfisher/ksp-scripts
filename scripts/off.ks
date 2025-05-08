if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/"). runpath("1:/knu.ks").
deletepath("1:/missions/m_body_orbit"). deletepath("1:/runmode").

local f is {
  parameter dirn.
  // Dirn, Pitch.
  // 90, 90 == due east, but straight up
  //  0, 90 == due north but straight up
  lock steering to heading(dirn, 90).
  lock throttle to 1.
  wait 2.
  lock steering to heading(dirn, 45).
  wait until apoapsis > 2000.
  lock throttle to 0.
}.

parameter d is 0.
f(d).