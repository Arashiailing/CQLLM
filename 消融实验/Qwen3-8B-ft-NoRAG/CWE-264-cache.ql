import python

/**
 * Detects potential stack trace exposure by checking for direct or indirect
 * usage of functions that output stack traces, such as traceback.format_exc(),
 * logging.exception(), or similar patterns.
 */
from Call c
where 
  (c.getSymbol().getName() = "traceback.format_exc" or
   c.getSymbol().getName() = "logging.exception" or
   c.getSymbol().getName() = "logging.error" and
   c.getArgument(0).getType().getName() = "Exception" or
   c.getSymbol().getName() = "print" and
   c.getArgument(0).getType().getName() = "TracebackException")
select c, "Potential stack trace exposure detected"