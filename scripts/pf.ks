// Passenger to Mun FULL script
//   runpath("0:/pf").
if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/"). runpath("1:/knu.ks").
deletepath("1:/missions/m_body_orbit"). deletepath("1:/runmode").
local i is import("missions/m_body_orbit").
i(Mun, list(22000,24000), true).

// use available thrust to reduce horizontal speed.
lock steering to retrograde. wait 5. lock throttle to 1.
wait until (ship:groundSpeed < 2 or ship:maxthrust < 1).
lock throttle to 0.
stage.
unlock steering.

runpath("0:/util/m", "m_land", false).
wait 0.5.
runpath("0:/util/m", "m_kerb_ret_from_landing", 12000).
