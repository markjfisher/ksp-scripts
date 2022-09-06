if not exists("1:/knu.ks") copypath("0:/knu.ks", "1:/").
runpath("1:/knu.ks").
local tr is import("transfer").
local freeze is tr:freeze.

runpath("0:/sinfo.ks").

function f1 {
  local si is stinfo().
  print si.
}

f1().