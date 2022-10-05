local tr is import("lib/transfer").
local mission is import("lib/mission").
local dbg is import("lib/ds").
local fr is tr:freeze.

local INF is 2^64.

local m is mission({ parameter seq, ev, next.
  seq:add({
    parameter a.
    local ta is choose a[0] if a:typename = "List" else a.
    tr:hohmann(ta).
    next().
  }).

}).

export(m).