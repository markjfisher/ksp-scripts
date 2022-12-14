{
  local f is "1:/runmode".
  export({
    parameter d.
    local r is 0.
    if exists(f) set r to import("runmode").
    local s is list().
    local e is lex().
    local n is {
      parameter m is r+1.
      if not exists(f) create(f).
      local h is open(f).
      h:clear().
      h:write("export("+m+").").
      set r to m.
    }.

    d(s,e,n).
    return {
      parameter w is "", x is "", y is "", z is "".
      until r >= s:length{
        if w = "" s[r](). else if x = "" s[r](w). else if y = "" s[r](w,x). else if z = "" s[r](w,x,y). else s[r](w,x,y,z).
        // never used this, but if I do, will need above to allow params.
        for v in e:values v().
        wait 0.
      }
    }.
  }).
}