if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/").
runpath("1:/knu.ks").
local tr is import("lib/transfer").

local f is {
  parameter t_wrp.
  if hasnode tr:exec(true, t_wrp). else {
    print "no node to execute.".
  }
}.

parameter t_wrp is 60.
f(t_wrp).