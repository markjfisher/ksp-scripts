local tr is import("lib/transfer").
local mission is import("lib/mission").
local dbg is import("lib/ds").
local fr is tr:freeze.

local INF is 2^64.
local RENT_BURNALT is 100000.

local m is mission({ parameter seq, ev, next.
  seq:add({
    parameter b, a, pro.
    local bms is addons:astrogator:calculateBurns(b).
    tr:seek_SOI(b, a, 0, 0, 10, bms, {
      parameter mnv.
      if not (mnv:orbit:hasnextpatch and mnv:orbit:nextpatch:body = b) return -INF.
    // prograde: get an inclination under 90
    // retrograde: get an inclination over 90.
      local i is abs(mnv:orbit:nextpatch:inclination).
      if pro {
        return choose 0 if i < 90 else -INF.
      } else {
        return choose 0 if i > 90 else -INF.
      }
    }).
    tr:exec(true, 40).
    next().
  }).
}).

export(m).