/**
 * @name CWE-295: Improper Certificate Validation
 * @description Request without certificate validation.
 *              Making a request without certificate validation can allow man-in-the-middle attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @id py/client-cwe-295
 * @tags security
 *       external/cwe/cwe-295
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs
import semmle.python.dataflow.new.TaintTracking
import CleartextLoggingFlow::PathGraph

from CleartextLoggingFlow::PathNode source, CleartextLoggingFlow::PathNode sink
where CleartextLoggingFlow::flowPath(source, sink)
select sink.getNode(),
  source,
  sink,
  "$@ flows to a clear-text logging location.",
  source.getNode(), 
  "Sensitive data"