// change base_mission.ks to your own mission script
if not exists("1:/knu.ks") copypath("0:/knu.ks", "1:/").
runpath("1:/knu.ks"). import("base_mission.ks")().