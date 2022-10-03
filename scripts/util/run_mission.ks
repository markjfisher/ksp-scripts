if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/"). runpath("1:/knu.ks").
parameter m.
deletepath("1:/missions"). deletepath("1:/runmode").
import("missions/" + m)().
