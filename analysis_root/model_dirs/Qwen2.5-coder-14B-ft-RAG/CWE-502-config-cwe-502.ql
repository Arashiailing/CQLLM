/**
 * @name Deserialization of user-controlled data
 * @description Deserializing user-controlled data may allow attackers to execute arbitrary code.
 * @id py/config-cwe-502
 * @kind problem
 * @problem.severity error
 * @security-severity 9.8
 * @sub-severity high
 * @precision high
 * @tags security
 *       serialization
 */

import python
import semmle.python.security.dataflow.UnsafeDeserializationQuery
import UnsafeDeserializationFlow::PathGraph

from UnsafeDeserializationFlow::PathNode source, UnsafeDeserializationFlow::PathNode sink
where UnsafeDeserializationFlow::flowPath(source, sink)
select sink.getNode(),
  source,
  sink,
  "Unsafe deserialization depends on a $@.",
  source.getNode(),
  source.toString()