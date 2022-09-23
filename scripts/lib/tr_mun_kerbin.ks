{
  local tr is lex("calc", calc@).
  local c is import("lib/tr_core").
  function calc {
    local h is orbit:semimajoraxis - body:radius.
    local dv is choose low(h) if h <= 150000 else hi(h).
    local a is ex_ang(h).
    local t is c:ex_t(a, Kerbin).
    return list(dv, t).
  }
  function low { parameter h. return 276.0675811 - 4.3850252e-4 * h + 8.892659E-10 * h * h. }
  function hi { parameter h. return 1224.8704 * h ^ (-0.14020622). }
  function ex_ang { parameter h. return 360 - 54.20074632 * constant:e ^ (-1.133811451E-6 * h). }
  export(tr).
}