import py

/**
 * @name CWE-203: Stack Trace Exposure
 * @description Detects potential exposure of stack traces through logging or error messages.
 */
from Method m, Call c
where 
  (m.getName() = "print_exc" and m.getModule() = "traceback") or
  (c.getCallee().getMethod().getName() = "format_exc" and c.getCallee().getModule() = "traceback") or
  (c.getMethod().getName() = "exception" and c.getModule() = "builtins") or
  (c.getMethod().getName() = "print" and exists(Argument a where a.getValue() = "exc_info"))
select c.getLocation(), "Potential stack trace exposure detected via traceback handling or exception printing."