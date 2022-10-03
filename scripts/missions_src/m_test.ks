local tr is import("lib/transfer").
local mission is import("lib/mission").

local TGT_MUNALT is 250000.
local INF is 2^64.

local m is mission({ parameter seq, ev, next.
  seq:add({
    print "test mission running".
    next().
  }).

  seq:add({
    local bm is addons:astrogator:calculateBurns(Mun).
    local t is bm[0]:atTime.
    local dv is bm[0]:totalDV.
    tr:seek_SOI(Mun, TGT_MUNALT, t, dv, 20, {
      parameter mnv.
      // get the inclination over 90. In practice it's either just over 0, or just under 180 for pro/retro
      if mnv:orbit:hasnextpatch {
        return choose -INF if mnv:orbit:nextpatch:inclination < 90 else 0.
      }
      // mo patch means it hasn't reached target
      return -INF.
    }).
    next().
  }).
}).

export(m).