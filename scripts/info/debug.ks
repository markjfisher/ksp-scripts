if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/").
runpath("1:/knu.ks").
local tr_km is import("lib/tr_kerbin_mun").
local tr_mk is import("lib/tr_mun_kerbin").
local tr is import("lib/transfer").
local dv is improot("lib/deltav").

local f1 is {
  local dv_x is tr_mk:calc().
  print "dv: " + dv_x[0].
  print " t: " + dv_x[1].
  set new_node to node(dv_x[1], 0, 0, dv_x[0]).
  add new_node.
}.

f1().