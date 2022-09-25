{
  local tr is lex("calc", calc@). local c is import("lib/tr_core"). local dbg is import("lib/ds").
  function calc {
    parameter debug is false.
    local h is orbit:semimajoraxis - body:radius.
    local dv is calc_dv(h).
    local t is c:ex_t(221, Minmus, 100, {
      parameter sT, eT, o.
      // mun intercept?
      local aS is o:ang(Mun, sT). local aE is o:ang(Mun, eT).
      local accept is choose false if (220 <= aS and aS <= 280) or (220 <= aE and aE <= 280) else true.
      if debug dbg:out("[k->min calc] sT: " + round(sT,3) + ", eT: " + round(eT,3) + ", aS: " + round(aS,3) + ", aE: " + round(aE,3) + ", accept: " + accept).
      return accept.
    }).
    if debug dbg:out("[k->min calc] returning dv, t: " + round(dv, 3) + ", " + round(t, 3)).
    return list(dv, t).
  }
  function calc_dv { parameter h. return (1097.8672 - 14.43394 * ln(h)) * 1.10. }
  export(tr).
}