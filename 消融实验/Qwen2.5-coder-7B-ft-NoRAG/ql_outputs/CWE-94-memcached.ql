/**
 * @name Memcached deserialization of user-controlled data
 * @description Deserializing user-controlled data from Memcached may allow attackers to execute arbitrary code.
 * @kind path-problem
 * @id py/memcached
 * @problem.severity error
 * @security-severity 9.8
 * @sub-severity high
 * @precision high
 * @tags external/cwe/cwe-502
 *       security
 *       serialization
 */

import python
import semmle.python.security.dataflow.UnsafeDeserializationQuery

from PathNode source, PathNode sink
where UnsafeDeserializationFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Unsafe deserialization from Memcached depends on a $@.", source.getNode(), "user-provided value"