{ local o is lex("norm", n@, "ang", a@).
  function n {
    parameter b. return vcrs(b:velocity:orbit:normalized, (b:body:position - b:position):normalized).
  }

  // see https://www.reddit.com/r/Kos/comments/ko7pxq/comment/ghovm8v/?utm_source=share&utm_medium=web2x&context=3
  function a { // phase angle between ship and target o1 via body of ship
    parameter o1, t is time:seconds.
    local pN is n(body). // normal to its current orbit plane of the shared body
    local bP is body:position.
    local v1 is vxcl(pN, (o1:position - bP):normalized).
    local v2 is vxcl(pN, (positionAt(ship, t) - bP):normalized).
    local ang is vang(v1, v2).
    if vdot(v2, vxcl(v1, o1:velocity:orbit)) < 0 {
      set ang to 360 - ang.
    }
    return ang.
  }

  export(o).
}