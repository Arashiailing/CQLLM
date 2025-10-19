/**
 * @name CWE-264: Unsafe Deserialization
 * @description Deserializing untrusted data can lead to arbitrary code execution.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @id py/unsafe-deserialization
 * @tags security
 */

import python
import semmle.python.security.dataflow.UnsafeDeserializationQuery
import UnsafeDeserializationFlow::PathGraph

from UnsafeDeserializationFlow::PathNode source, UnsafeDeserializationFlow::PathNode sink
where UnsafeDeserializationFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Unsafe deserialization depends on a $@.", source.getNode(), "user-provided value"