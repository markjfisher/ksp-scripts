{
  local s is stack().
  local d is lex().

  global import is {
    parameter n. // name of import script
    s:push(n).
    if not exists("1:/" + n) copypath("0:/" + n, "1:/"+n).
    runpath("1:/" + n).
    return d[n].
  }.

  // import without the local copy
  global improot is {
    parameter n. // name of import script
    s:push(n).
    runpath("0:/" + n).
    return d[n].
  }.

  global export is {
    parameter v.
    set d[s:pop()] to v.
  }.
}