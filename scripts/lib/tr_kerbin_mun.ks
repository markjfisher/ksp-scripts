{
  local tr is lex("calc", calc@).
  local c is import("lib/tr_core").
  function calc {
    local h is orbit:semimajoraxis - body:radius.
    local dv is choose low(h) if h <= 400000 else hi(h).
    local t is c:ex_t(ex_ang(h), Mun).
    return list(dv, t).
  }
  function low { parameter h. return 915.2101071 - 8.46510532e-4 * h + 6.157517419e-10 * h * h. }
  function hi { parameter h. return 3742.0101 - 236.51475 * ln(h). }
  function ex_ang { parameter h. return 242.830928 + 5.632302405e-6 * h. }
  export(tr).
}