local tr is import("lib/transfer").
local mission is import("lib/mission").
local dbg is import("lib/ds").
local descent is import("lib/descent").
local fr is tr:freeze.

local INF is 2^64.
local RENT_BURNALT is 100000.

local m is mission({ parameter seq, ev, next.
  seq:add({
    gear on.
    descent:suicide_burn(3000).
    if stage:number >= 2 {
      lock throttle to 0. wait 0.5. stage. wait 2.
    }
    descent:suicide_burn(50).
    descent:seek_landing_area().
    descent:powered_landing().
    next().
  }).
}).

export(m).