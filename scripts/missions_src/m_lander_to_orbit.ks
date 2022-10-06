local tr is import("lib/transfer").
local mission is import("lib/mission").
local descent is import("lib/descent").

local TGT_RETALT is 35000.
local RENT_BURNALT is 100000.

local fr is tr:freeze.
local warping is false.

// Parameters to blocks:
// a = target altitude around body to achieve and circ before transfer to kerbin

local m is mission({ parameter seq, ev, next.
  seq:add({
    parameter a.

    // get into orbit
    lock steering to heading(90, 90).
    lock throttle to 1.
    wait 3.
    lock steering to heading(90, 45).
    wait until apoapsis > a.
    lock throttle to 0.
    gear off.

    // circularize at apo as we just took off
    tr:circ_apo(20).
    next().
  }).

}).

export(m).