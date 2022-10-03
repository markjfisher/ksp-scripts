{ local o is lex("norm", n@, "ang", a@, "circ_node", circ_node@, "cap_circ_node", cap_circ_node@).
  function n {
    parameter b. return vcrs(b:velocity:orbit:normalized, (b:body:position - b:position):normalized).
  }

  // see https://www.reddit.com/r/Kos/comments/ko7pxq/comment/ghovm8v/?utm_source=share&utm_medium=web2x&context=3
  function a { // phase angle between ship and target o1 via body of ship
    parameter o1, t is time:seconds.
    local pN is n(body). // normal to its current orbit plane of the shared body
    local bP is body:position.
    local v1 is vxcl(pN, (positionAt(o1, t) - bP):normalized).
    local v2 is vxcl(pN, (positionAt(ship, t) - bP):normalized).
    local ang is vang(v1, v2).
    if vdot(v2, vxcl(v1, o1:velocity:orbit)) < 0 {
      set ang to 360 - ang.
    }
    return ang.
  }

  function circ_node {
    // This is for kerbin circ when already in orbit...
    parameter wait_alt is false, alt_height is 70000.
    if wait_alt wait until (altitude > 70000).
    local futurevelocity is sqrt(velocity:orbit:mag^2 - 2 * body:mu * (1 / (body:radius + altitude) - 1 / (body:radius + orbit:apoapsis))).
    local circvelocity is sqrt(body:mu/(orbit:apoapsis + body:radius)).
    local newnode is node(time:seconds+eta:apoapsis, 0, 0, circvelocity-futurevelocity).
    add newnode.
  }

  function cap_circ_node {
    parameter wait_alt is false, alt_height is 70000.
    if wait_alt wait until (altitude > 70000).
    local futurevelocity is sqrt(velocity:orbit:mag^2 - 2 * body:mu * (1 / (body:radius + altitude) - 1 / (body:radius + orbit:periapsis))).
    local circvelocity is sqrt(body:mu/(orbit:periapsis + body:radius)).
    local newnode is node(time:seconds+eta:periapsis, 0, 0, circvelocity-futurevelocity).
    add newnode.
  }

  export(o).
}