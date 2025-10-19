/**
* @name Clear text logging of sensitive information
* @description Logging sensitive information in clear text may lead to exposure of private data.
* @kind path-problem
* @id py/clear-text-logging
* @problem.severity error
* @security-severity 6.5
* @precision high
* @tags security
*       external/cwe/cwe-312
*/

import python
import semmle.python.security.dataflow.ClearTextLoggingQuery
import CleartextLoggingFlow::PathGraph

from CleartextLoggingFlow::PathNode source, CleartextLoggingFlow::PathNode sink
where CleartextLoggingFlow::flowPath(source, sink)
select sink.getNode(), source, sink,
  "$@ is logged as clear text.", source.getNode(),
  "Sensitive data"