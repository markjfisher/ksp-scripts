// Run another mission script, allowing up to 4 parameters to be passed to it.

if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/"). runpath("1:/knu.ks").
parameter m, w is "", x is "", y is "", z is "".
deletepath("1:/missions/"+m). deletepath("1:/runmode").
local i is import("missions/" + m).
if w = "" i(). else if x = "" i(w). else if y = "" i(w,x). else if z = "" i(w,x,y). else i(w,x,y,z).
