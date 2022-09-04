{
  local s is stack().
  local d is lex().

  global import is {
    parameter name.
    s:push(name).
    if not exists("1:/" + name) copypath("0:/" + name, "1:/").
    runpath("1:/" + name).
    return d[name].
  }.

  // import without the local copy
  global improot is {
    parameter name.
    s:push(name).
    runpath("0:/" + name).
    return d[name].
  }.

  global export is {
    parameter v.
    set d[s:pop()] to v.
  }.
}