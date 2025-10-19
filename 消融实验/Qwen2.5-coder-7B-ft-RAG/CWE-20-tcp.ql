/**
 * @name Cleartext logging of sensitive information
 * @description Sensitive information such as passwords and tokens should not be logged in cleartext.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 5.0
 * @precision high
 * @id py/CleartextLoggingQuery
 * @tags security
 *       external/cwe/cwe-20
 */

import python
import semmle.python.security.dataflow.CleartextLoggingQuery
import CleartextLoggingFlow::PathGraph

from CleartextLoggingFlow::PathNode source, CleartextLoggingFlow::PathNode sink
where CleartextLoggingFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Cleartext logging occurs because the data flows from $@.", source.getNode(),
  "user-controlled input"