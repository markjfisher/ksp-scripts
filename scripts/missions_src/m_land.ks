local mission is import("lib/mission").
local descent is import("lib/descent").

// just land from current orbit around the body.

// Parameters:
//  seek: boolean, if true, seek a safe landing area - burns a lot of fuel as it uses hovering. default false.

local m is mission({ parameter seq, ev, next.
  // landing
  seq:add({
    parameter seek is false.
    gear on.
    // allow for any custom action groups while landing, e.g. robotics
    ag1 on.
    descent:suicide_burn(3000).
    if stage:number >= 2 {
      lock throttle to 0. wait 2. stage. wait 3.
    }
    descent:suicide_burn(50).
    if seek {
      descent:seek_landing_area().
    }
    descent:powered_landing().
    next().
  }).
}).

export(m).