core:part:getmodule("kOSProcessor"):doevent("Open Terminal").

if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/").
runpath("1:/knu.ks").
wait 5.
improot("launch.ks"):exec(0, 40).