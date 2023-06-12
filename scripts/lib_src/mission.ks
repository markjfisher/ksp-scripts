// Runs mission scripts, see missions_src for examples.
{
  local f is "1:/runmode".
  export({
    parameter d.
    local r1 is 0.
    if exists(f) set r1 to import("runmode").
    local s is list().
    local e is lex().
    local n is {
      parameter m is r1+1.
      if not exists(f) create(f).
      local h is open(f).
      h:clear().
      h:write("export("+m+").").
      set r1 to m.
    }.

    d(s,e,n).
    return {
      parameter w is "", x is "", y is "", z is "".
      until r1 >= s:length{
        if w = "" s[r1](). else if x = "" s[r1](w). else if y = "" s[r1](w,x). else if z = "" s[r1](w,x,y). else s[r1](w,x,y,z).
        // never used this, but if I do, will need above to allow params.
        for v1 in e:values v1().
        wait 0.
      }
    }.
  }).
}