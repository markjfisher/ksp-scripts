if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/"). runpath("1:/knu.ks").
parameter m, w is "", x is "", y is "", z is "".
deletepath("1:/missions/"+m).deletepath("1:/runmode").
import("missions/" + m)(w,x,y,z).
