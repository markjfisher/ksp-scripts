seq:add({
  tr:seek(
    fr(time:seconds + eta:periapsis), fr(0), fr(0), 0,
      { parameter mnv. return - abs(0.5 - mnv:orbit:eccentricity). }).
  tr:exec(true).
  next().
}).