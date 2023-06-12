if not exists("1:/knu.ks") copypath("0:/lib/knu.ks", "1:/").
runpath("1:/knu.ks").
local tr is import("lib/transfer").
local freeze is tr:freeze.

// Set Inclination, Eccentricity, Apoapsis and Periapsis around current body.
// Current values are assumed if not supplied, i.e. ship's current Ap and Pe are default, so you can just change Inc and Ecc.

// This is useful to change inclination easily.
// Precise times can be made for when to perform maneuveur by creating a dummy node where you want to execute it, then run as follows:

// runpath("0:/util/ie", 15, 0.00001, nextnode:time)

// Final parameter of true will perform the maneuveur, but the node can be manually executed with 'util/xn', so
// you can judge if this maneuveur is too expensive before performing it.

local f1 is {
  parameter inc, ecc, atT, newPeri, newApo, doIt.
  local incFactor is choose 0 if inc = ship:orbit:inclination else 1000.
  local eccFactor is choose 0 if ecc = ship:orbit:eccentricity else 10000.
  local periFactor is choose 0 if newPeri = ship:orbit:periapsis else 1/1500.
  local apoFactor is choose 0 if newApo = ship:orbit:apoapsis else 1/1500.

  tr:seek(
    // use UT for time, so we can pass in things like addons:astrogator:timeOfShipAN, etc. without having to adjust for now time.
    freeze(atT),
    0, // radial - x
    0, // normal - y
    0, // progrd - z
    20, // step for seeking
    list(), // existing BurnModels is empty
    {
      parameter mnv.
      local incContrib is abs(inc - mnv:orbit:inclination) * incFactor.
      local eccContrib is abs(ecc - mnv:orbit:eccentricity) * eccFactor.
      local periContrib is abs(mnv:orbit:periapsis - newPeri) * periFactor.
      local apoContrib is abs(mnv:orbit:apoapsis - newApo) * apoFactor.
      local distContrib is periContrib + apoContrib.
      local result is -(incContrib + eccContrib + distContrib).
      // print "result: " + result + " (i: " + incContrib + ", e: " + eccContrib + ", D: " + distContrib + ")".
      return result.
    }
  ).
  if doIt {
    tr:exec(true, 90).
  }
}.

parameter inc is 0, ecc is 0, atT is addons:astrogator:timeOfShipAN, newPeri is ship:orbit:periapsis, newApo is ship:orbit:apoapsis, doIt is false.
f1(inc, ecc, atT, newPeri, newApo, doIt).