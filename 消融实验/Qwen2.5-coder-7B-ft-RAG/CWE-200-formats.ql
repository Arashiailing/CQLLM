/**
 * @name Cleartext Logging Query
 * @description Detects logging operations that output sensitive information without encryption.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 5.0
 * @precision medium
 * @id py/cleartext-logging-query
 * @tags security
 *       external/cwe/cwe-200
 */

import python
import semmle.python.security.dataflow.CleartextLoggingQuery
import CleartextLoggingFlow::PathGraph

from CleartextLoggingFlow::PathNode source, CleartextLoggingFlow::PathNode sink
where CleartextLoggingFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This logging operation includes a $@.", source.getNode(),
  "user-provided value"