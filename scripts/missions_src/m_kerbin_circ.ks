local mission is import("lib/mission").
local launch is improot("launch").

local m is mission({ parameter seq, ev, next.
  seq:add({
    parameter a.
    if ship:status = "prelaunch" launch:exec(0, a / 1000, false).
    next().
  }).

  seq:add({
    parameter a.
    print "kerbin orbit established.".
    next().
  }).

}).

export(m).