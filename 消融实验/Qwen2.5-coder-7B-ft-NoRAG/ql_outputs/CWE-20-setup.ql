/**
 * @name CWE-20: Improper Input Validation
 * @id py/setup
 */

import python
import semmle.python.security.dataflow.InsecureInputValidationQuery

from InsecureInputValidationFlow::PathNode source, InsecureInputValidationFlow::PathNode sink
where InsecureInputValidationFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Insecure input validation found."