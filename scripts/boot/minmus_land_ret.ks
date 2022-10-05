if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/").
runpath("1:/knu.ks"). import("missions/m_body_land_ret")(Minmus, list(12000, 300000), false).