local mission is import("lib/mission").
local launch is improot("launch").

// Mission to launch and be in orbit around kerbin.

// Parameter:
//  a = altitude in metres for orbit (e.g. 82000)
//  heading = 90 for E, 0 for N, etc.

local m is mission({ parameter seq, ev, next.
  seq:add({
    parameter a, dH.
    if ship:status = "prelaunch" launch:exec(0, a / 1000, dH).
    next().
  }).

  seq:add({
    parameter a.
    print "kerbin orbit established.".
    next().
  }).

}).

export(m).