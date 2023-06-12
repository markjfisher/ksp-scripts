// this is to change the SATNAT probe inclination by the given delta (negative to reduce).

local f is {
  parameter i_d, t_wrp.
  set t_x to max(addons:astrogator:timeOfShipAN, addons:astrogator:timeOfShipDN).
  set i_x to round(orbit:inclination, 0) + i_d.
  runpath("0:/util/ie", i_x, 0.00000001, t_x - time:seconds).
  runpath("0:/util/xn", t_wrp).
}.

parameter inclination_delta, t_wrp is 20.
f(inclination_delta, t_wrp).
