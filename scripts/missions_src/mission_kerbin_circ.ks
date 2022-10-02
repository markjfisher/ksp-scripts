local mission is import("lib/mission").
local launch is improot("launch").

local TGT_ALT is 840000.

local m is mission({ parameter seq, ev, next.
  seq:add({
    launch:exec(0, TGT_ALT / 1000, false).
    next().
  }).

  seq:add({
    print "kerbin orbit established.".
    next().
  }).

}).

export(m).