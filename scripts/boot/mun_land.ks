if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/").
runpath("1:/knu.ks"). import("missions/m_body_land")(Mun, list(13000, 16000)).