import python

/**
 * @name CWE-532: Cleartext Logging
 * @description Detects writing of sensitive information to logs.
 */
from Call c
where c.module.name = "logging"
  and c.method.name in ("debug", "info", "warning", "error", "critical")
  and c.arguments.size() > 0
  and exists(Argument a |
    a.call = c
    and a.value is Variable
    and a.value.isSecret()
  )
select c.location, "Sensitive information logged in a log statement."