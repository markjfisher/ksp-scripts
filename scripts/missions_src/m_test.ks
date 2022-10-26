local tr is import("lib/transfer").
local mission is import("lib/mission").
local dbg is import("lib/ds").
local descent is import("lib/descent").
local fr is tr:freeze.

local INF is 2^64.
local RENT_BURNALT is 100000.

local m is mission({ parameter seq, ev, next.
  seq:add({
    next().
  }).
}).

export(m).