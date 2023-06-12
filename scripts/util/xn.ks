// Executes all nodes queued up.
// Useful if you setup nodes with Astrogator to seek an intercept, or perform inclination changes from 'util/ie' script.

// runpath("0:/util/xn").

// Parameters:
//  t_wrp: number [OPTIONAL] - the time before node's time to warp to,
//         giving ship time to set correct heading before executing.
//         default: 40 (seconds)

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