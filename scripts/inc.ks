// this is to change the SATNAT probe by the given increment (negative to reduce).

local f is {
  parameter inc.
  set t to max(addons:astrogator:timeOfShipAN, addons:astrogator:timeOfShipDN).
  set i to round(orbit:inclination, 0) + inc.
  runpath("0:/util/set_inc_ecc", i, 0, t - time:seconds).
  runpath("0:/util/do_node", 20).
}.

parameter inclination_increment.
f(inclination_increment).
