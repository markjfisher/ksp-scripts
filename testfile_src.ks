function suicide_burn {
  parameter cutoff.
  local t is 0. lock throttle to t.
  local has_impact_time is {
    local a is (g() * (1 - (availtwr() * max(cos(vang(up:vector, ship:facing:vector)), NIL)))).
    local v is -verticalspeed.
    local d is radar() - cutoff.
    return v^2 + 2*a*d > 0.
  }.
  lock steering to descent_vector().
  until radar() < cutoff or ship:availablethrust < 0.1 {
    if has_impact_time() set t to 1.
    else set t to 0.
    wait 0.001.
  }
}
