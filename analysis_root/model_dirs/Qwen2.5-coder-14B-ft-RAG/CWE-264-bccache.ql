/**
 * @name CWE-264: Unsafe Deserialization
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @id py/cwe-264
 * @tags security
 *       external/cwe/cwe-502
 */

import python
import semmle.python.security.dataflow.UnsafeDeserializationQuery
import UnsafeDeserializationFlow::PathGraph

from 
  UnsafeDeserializationFlow::PathNode source, 
  UnsafeDeserializationFlow::PathNode sink
where 
  UnsafeDeserializationFlow::flowPath(source, sink)
select 
  sink.getNode(), 
  source, 
  sink, 
  "Unsafe deserialization depends on a $@.", 
  source.getNode(), 
  "user-provided value"