{ local o is lex("norm", n@, "ang", a@).
  function n { // normal plane of b's orbit
    parameter b. return vcrs(b:orbit:velocity:orbit:direction:forevector, (b:position - b:body:position):normalized).
  }
  function a { // angle between ship, it's parent and targetBody in plane of parent at time t
    parameter tB. parameter t is time:seconds.
    local pN is n(body). local bP is positionAt(body, t).
    local vT is vxcl(pN, positionAt(tB, t) - bP).
    local vS is vxcl(pN, positionAt(ship, t) - bP).
    return vang(vT, vS).
  }
  export(o).
}