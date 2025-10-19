import py

from MethodCall mc
where
  (mc.getMethodName() = "get" or mc.getMethodName() = "post") and
  mc.getCallee() = py.Module("requests", "requests") and
  not exists (mc.getArguments().Argument where name = "verify" and value = true)
select mc, "Request without certificate validation. This can allow man-in-the-middle attacks."