// Debug over socket.
// Useful for sending debug information to telnet client.

// Usage: dbg:out(<string>).

// {
//   local dbg is import("lib/ds").
//   function foo { parameter a. dbg:out("your output: " + a). }
//   foo(1).
// }

{
  // debug over socket
  local ds is lex("out", d@).

  function d {
    parameter m, p is 40000.
    local s is addons:sock:connect("127.0.0.1", p).
    s:send(m + char(10)). s:close().
  }
  export(ds).
}