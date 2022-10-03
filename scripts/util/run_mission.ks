if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/"). runpath("1:/knu.ks").
parameter m.
import("missions/" + m)().
