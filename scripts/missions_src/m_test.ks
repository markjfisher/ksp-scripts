local tr is import("lib/transfer_debug").
local mission is import("lib/mission").
local dbg is import("lib/ds").

local TGT_MUNALT is 250000.
local INF is 2^64.

local m is mission({ parameter seq, ev, next.
  seq:add({
    parameter b, a.
    local bm is addons:astrogator:calculateBurns(b).
    tr:seek_SOI(b, a, bm[0]:atTime, bm[0]:totalDV, 100, {
      parameter mnv.
      return choose 0 if (mnv:orbit:hasnextpatch and mnv:orbit:nextpatch:body = b) else -INF.
    }).
    if not hasnode or not (nextnode:orbit:hasnextpatch and nextnode:orbit:nextpatch:body = b) {
      dbg:out("Failed to get SOI to: " + b).
      print 1/0.
    }

    // tr:exec(true, 40).
    next().
  }).
}).

export(m).