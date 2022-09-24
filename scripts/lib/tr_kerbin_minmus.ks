{
  local tr is lex("calc", calc@). local c is import("lib/tr_core").
  function calc {
    local h is orbit:semimajoraxis - body:radius.
    local dv is calc_dv(h).
    local t is c:ex_t(221, Minmus, 100, {
      parameter sT, eT, o.
      // mun intercept?
      local aS is o:ang(Mun, sT). local aE is o:ang(Mun, eT).
      if (220 <= aS and aS <= 280) or (220 <= aE and aE <= 280) return false.
      return true.
    }).
    return list(dv, t).
  }
  function calc_dv { parameter h. return (1097.8672 - 14.43394 * ln(h)) * 1.10. }
  export(tr).
}