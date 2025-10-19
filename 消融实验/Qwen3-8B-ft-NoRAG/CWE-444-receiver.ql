import py

from Call call, Call call2
where
  call.getMethod() = "set_header" and
  call.getArg(0) = "Content-Length" and
  call.getArg(1) is Int and
  call2.getMethod() = "set_header" and
  call2.getArg(0) = "Transfer-Encoding" and
  call2.getArg(1) = "chunked" and
  call.getPos().getFunction() = call2.getPos().getFunction()
select call, call2, "Potential HTTP request smuggling due to inconsistent Content-Length and Transfer-Encoding headers"