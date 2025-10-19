import python

/**
 * Detects potential exposure of sensitive information through logging or print statements.
 */
from Call c
where 
  (c.getName() = "print" and c.getNumArgs() > 0) or
  (c.getName().startsWith("logging.") and c.getName().endsWith("Log")) or
  (c.getName() = "sys.stderr.write")
select c, "Potential exposure of sensitive information via logging/print statement"