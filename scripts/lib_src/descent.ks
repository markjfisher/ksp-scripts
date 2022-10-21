{
  local NIL is 0.0001.
  local descent is lex(
    "suicide_burn", suicide_burn@,
    "powered_landing", pow_land@,
    "seek_landing_area", seek_land@
  ).

  function suicide_burn {
    parameter cutoff.
    local t is 0. lock throttle to t.
    local has_impact_time is {
      local a is (g() * (1 - (availtwr() * max(cos(vang(up:vector, ship:facing:vector)), NIL)))).
      local v is -verticalspeed.
      local d is radar() - cutoff.
      return v^2 + 2*a*d > 0.
    }.
    lock steering to desc_v().
    until radar() < cutoff or ship:availablethrust < 0.1 {
      if has_impact_time() set t to 1.
      else set t to 0.
      wait 0.001.
    }
  }

  function pow_land {
    local t is 0. lock throttle to t.
    lock steering to desc_v().
    until alt:radar < 15 { set t to hover(-7). wait 0. }
    until velocity:surface:mag < 0.5 { set t to hover(0). wait 0. }
    until ship:status = "Landed" { set t to hover(-2). wait 0. }
    set t to 0.
  }

  local hPID is pidloop(2.7, 4.4, 0.12, 0, 1).
  function hover {
    parameter sp. // setpoint
    set hPID:setpoint to sp.
    set hPID:maxoutput to availtwr().
    return min(
      hPID:update(time:seconds, ship:verticalspeed) /
        max(cos(vang(up:vector, ship:facing:vector)), 0.0001) /
        max(availtwr(), 0.0001),
        1
      ).
  }

  // descent vector
  function desc_v {
    if vang(srfretrograde:vector, up:vector) > 90 return ur(up).
    return ur(up:vector * g() - velocity:surface).
  }

  // unrotate a vector
  function ur {
    parameter v. if v:typename <> "Vector" set v to v:vector.
    return lookdirup(v, ship:facing:topvector).
  }

  function radar {
    return altitude - body:geopositionof(ship:position):terrainheight.
  }

  function g { return body:mu / ((ship:altitude + body:radius)^2). }
  function availtwr { return ship:availablethrust / (ship:mass * g()). }

  function seek_land {
    local ALS is 7.2.   // acceptable landing slope
    local ADR is 0.75.  // acceptable drift
    local DES_VEL is 4. // the velocity to shift ourselves over at
    // target vector
    local tv is ur(up).
    local t is 1.

    lock throttle to t.
    lock steering to tv.
    local s is vang(grsl(), up:vector).

    until s < ALS and velocity:surface:mag < ADR {
      set s to vang(grsl(), up:vector).
      // desired velocity
      local des_v is vxcl(up:vector, grsl()).
      set des_v:mag to DES_VEL.
      if s < ALS set des_v to v(0, 0, 0).
      local dv is des_v - velocity:surface.
      set tv to ur(up:vector * g() + dv).
      set t to hover(0).
      wait 0.
    }
  }

  // ground slope
  function grsl {
    // scaling factor for vectors around ship position to check for slopes
    local m is 5.
    local r3d2 is sqrt(3) / 2 * m. // pre-multiply by m.
    local n is north:vector.
    local sp is ship:position.
    local e is vcrs(n, up:vector).
    // a, b, c are equalateral triangle points around ship position.
    // AB = AC = BC = sqrt(3), perpendicular length = 1.5, so centre to A is 1, to base is 0.5.
    // then adjust by factor m to scale it out.
    local a is body:geopositionof(sp + m * n).
    local eb is r3d2 * e.     // east bit
    local db is (m / 2) * n.  // down bit
    local b is body:geopositionof(sp - db + eb).
    local c is body:geopositionof(sp - db - eb).

    local av is a:altitudeposition(a:terrainheight).
    // save some space by not pre-calculating, as only used once
    // local bv is b:altitudeposition(b:terrainheight).
    // local cv is c:altitudeposition(c:terrainheight).

    return vcrs(c:altitudeposition(c:terrainheight) - av, b:altitudeposition(b:terrainheight) - av).
  }

  export(descent).
}