function log_telemetry {
  local output is "[".
// Time
  set output to output + (time:seconds - start_time) + ",".

// Altitude
  set output to output + alt:radar + ",".

// Angle
  set angle to 90 - vang(up:vector, ship:facing:vector).
  set output to output + angle + ",".

// Apoapsis
  set output to output + apoapsis + ",".

// Eccentricity
  set output to output + obt:eccentricity + ",".

// DeltaV
  list engines in ship_engines.
  set dry_mass to ship:mass - ((ship:liquidfuel + ship:oxidizer) * 0.005).
  set delta_v to ship_engines[0]:isp * 9.81 * ln(ship:mass / dry_mass).
  set output to output + delta_v + "],".

  log output to "output/ascent.js".
}

print "Toggle RCS to launch".
wait until rcs.
set start_time to time:seconds.
hudtext("Beginning test", 5, 2, 50, yellow, false).
switch to 0.
log "" to "output/ascent.js". deletepath("output/ascent.js").
log "var data = [['Time','Altitude','Angle','Apoapsis','Eccentrity','DeltaV']," to "output/ascent.js".
until ship:liquidfuel < 1 or verticalspeed < -5 {
  log_telemetry().
  wait 0.1.
}
log "];" to "output/ascent.js".

hudtext("Test Complete!", 5, 2, 50, yellow, false).
wait 5.
// kuniverse:reverttolaunch().