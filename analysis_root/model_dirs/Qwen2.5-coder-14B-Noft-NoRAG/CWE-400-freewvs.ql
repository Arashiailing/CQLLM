import python

/**
 * CWE-400: Uncontrolled Resource Consumption
 * Detects instances where a resource is not properly controlled.
 */

from Function f, Call call
where f.getName() = "open" and call.getCallee() = f
select call, "This call to 'open' may lead to uncontrolled resource consumption."