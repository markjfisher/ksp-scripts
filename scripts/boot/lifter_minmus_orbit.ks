if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/").
runpath("1:/knu.ks"). import("missions/m_lifter_body_orbit")(Minmus, list(12000, 500000), true).