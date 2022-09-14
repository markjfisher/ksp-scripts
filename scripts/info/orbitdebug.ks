runpath("0:/info/diraxesundo").
clearvecdraws().
lock p1 to -body:position:normalized.
lock p3 to orbit:velocity:orbit:direction:forevector.
lock p2 to vcrs(p3, p1).
set ap1 to vecdraw(v(0,0,0), p1 * 500000, yellow, "x", 1, true, 0.2, true, true).
set ap2 to vecdraw(v(0,0,0), p2 * 500000, red, "y", 1, true, 0.2, true, true).
set ap3 to vecdraw(v(0,0,0), p3 * 500000, blue, "z", 1, true, 0.2, true, true).
set apAV to vecdraw(v(0,0,0), ship:angularvel:normalized * 1000000, white, "angv", 1, true, 0.2, true, true).
runpath("0:/info/diraxesdraw", ship:orbit:velocity:orbit:direction, white, 400000, "s_orb_dir").
local ya is vang(p2, ship:orbit:velocity:orbit:direction:upvector).
local roll is ship:orbit:velocity:orbit:direction:roll.
print "ya: " + ya + ", roll: " + roll.
