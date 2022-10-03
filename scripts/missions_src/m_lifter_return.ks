local mission is import("lib/mission").

// This script waits until body returns below APPLY_TG_HEIGHT after first reaching ORBIT_HEIGHT_CHECK
// and then does action group 9. Put parachutes etc on this, and other stuff to do.
// Could also burn the last fuel off?

// AG9 is parachute action group.

local ORBIT_HEIGHT_CHECK is 50000.
local APPLY_AG_HEIGHT is 10000.

local m is mission({ parameter seq, ev, next.
  seq:add({
    if altitude > ORBIT_HEIGHT_CHECK {
      print "reached orbit height".
      next().
    }
    wait 0.5.
  }).

  seq:add({
    if altitude < APPLY_AG_HEIGHT {
      print "descended below ag height".
      next().
    }
    wait 0.5.
  }).

  seq:add({
    print "triggering ag9". ag9 on. wait 0.
    next().
  }).
}).

export(m).
