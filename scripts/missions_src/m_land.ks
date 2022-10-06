local mission is import("lib/mission").
local descent is import("lib/descent").

// just land from current orbit around the body.

local m is mission({ parameter seq, ev, next.
  // landing
  seq:add({
    gear on.
    descent:suicide_burn(3000).
    if stage:number >= 2 {
      lock throttle to 0. wait 0.1. stage. wait 0.1.
    }
    descent:suicide_burn(50).
    descent:powered_landing().
    next().
  }).
}).

export(m).