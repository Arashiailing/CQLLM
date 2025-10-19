/**
 * @name Deserialization of user-controlled data
 * @description Deserializing user-controlled data may allow attackers to execute arbitrary code.
 * @kind path-problem
 * @id py/unsafe-deserialization
 * @problem.severity error
 * @security-severity 9.8
 * @sub-severity high
 * @precision high
 * @tags external/cwe/cwe-502
 *       security
 *       serialization
 */

// Import Python code analysis capabilities
import python

// Import specialized modules for unsafe deserialization detection
import semmle.python.security.dataflow.UnsafeDeserializationQuery

// Import path visualization components for data flow tracking
import UnsafeDeserializationFlow::PathGraph

// Identify data flow paths between entry points and dangerous operations
from UnsafeDeserializationFlow::PathNode origin, UnsafeDeserializationFlow::PathNode destination
// Ensure complete data flow propagation from source to sink
where UnsafeDeserializationFlow::flowPath(origin, destination)
// Report findings with path context and vulnerability details
select destination.getNode(), origin, destination, "Unsafe deserialization depends on a $@.", origin.getNode(),
  "user-provided value"