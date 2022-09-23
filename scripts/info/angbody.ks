if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/").
runpath("1:/knu.ks").
local o is import("lib/orbit").

// calculate the angle at time t between ship and target body relative to the current body
local f1 is {
  parameter o1, t.
  local a is o:ang(o1, t).
  return a.
}.

parameter po1, at_t is time:seconds.
local a is f1(po1, at_t).
print "angles: " + a.