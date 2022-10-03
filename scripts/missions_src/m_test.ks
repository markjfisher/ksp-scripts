local mission is import("lib/mission").

local m is mission({ parameter seq, ev, next.
  seq:add({
    print "test mission running".
    next().
  }).

}).

export(m).