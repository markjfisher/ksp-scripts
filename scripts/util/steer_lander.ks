// A script to hover a ship, and move it with WASD keys
// with =- to increase/decrease the height
// Press Q to quit.
// May have to change keys depending on if they filter

// NOT FULLY TESTED

if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/").
runpath("1:/knu.ks").
local descent is import("lib/descent").

local f is {
  local target_twr is 0.
  local e is heading(90, 0):vector.
  local n is heading(0, 0):vector.
  local u is up:vector.
  local g is 0.
  local maxtwr is 0.
  local delta_velocity is 0.

  lock g to body:mu / ((ship:altitude + body:radius)^2).

  local desired_velocity is v(0, 0, 0).
  lock delta_velocity to desired_velocity - velocity:surface.
  lock steering to lookdirup(u * g + delta_velocity, ship:facing:topvector).

  lock maxtwr to ship:maxthrust / (g * ship:mass).
  lock throttle to min(target_twr / maxtwr, 1).

  set ship:control:pilotmainthrottle to 0.

  local sp is 0.
  local pid is pidloop(2.7, 4.4, 0.12, 0, maxtwr).
  set pid:setpoint to sp.

  local keep_running is 1.

  local ch is "".
  until keep_running = 0 {
    if terminal:input:haschar {
      set ch to terminal:input:getchar().
      print "processing input: " + ch.
    }
    if ch = "q" { set keep_running to 0. }
    if ch = "w" { set desired_velocity to desired_velocity + n. }
    if ch = "s" { set desired_velocity to desired_velocity - n. }
    if ch = "a" { set desired_velocity to desired_velocity - e. }
    if ch = "d" { set desired_velocity to desired_velocity + e. }
    if ch = "=" { set sp to sp + 1. set pid:setpoint to sp. }
    if ch = "-" { set sp to sp - 1. set pid:setpoint to sp. }
    if keep_running = 1 {
      set target_twr to pid:update(time:seconds, ship:verticalspeed) / max(cos(vang(up:vector, ship:facing:vector)), 0.0001).
      wait 0.01.
    }
    set ch to "".
  }

  unlock throttle.
  set throttle to 0.
  unlock steering.
  descent:powered_landing().
}.

f().