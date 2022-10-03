local tr is import("lib/transfer").
local mission is import("lib/mission").

local TGT_MUNALT is 250000.
local INF is 2^64.

local m is mission({ parameter seq, ev, next.
  seq:add({
    parameter pro.
    local bm is addons:astrogator:calculateBurns(Mun).
    local t is bm[0]:atTime.
    local dv is bm[0]:totalDV * 1.01. // add 1% to the dv as a start to give it the boost to start closer to retro
    tr:seek_SOI(Mun, TGT_MUNALT, t, dv, 20, {
      parameter mnv.
      // prograde: get an inclination under 90
      // retrograde: get an inclination over 90.
      if mnv:orbit:hasnextpatch {
        if pro {
          return choose 0 if abs(mnv:orbit:nextpatch:inclination) < 90 else -INF.
        } else {
          return choose 0 if abs(mnv:orbit:nextpatch:inclination) > 90 else -INF.
        }
      }
      // no patch means it hasn't reached target
      return -INF.
    }).
    next().
  }).
}).

export(m).