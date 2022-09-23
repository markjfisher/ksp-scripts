if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/").
runpath("1:/knu.ks").
local tr is import("lib/transfer").

local f1 is {
  if hasnode tr:exec(true). else {
    print "no node to execute.".
  }
}.

f1().