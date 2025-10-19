/**
* @name Memcached deserialization vulnerability
*
@description Deserializing data
from an untrusted source using memcached can allow attackers to execute arbitrary code.
*
@id py/memcached
* @problem.severity error
* @security-severity 9.8
* @sub-severity high
* @precision high
*
@tags external/cwe/cwe-502 * security * serialization
*/
import python
import semmle.python.security.dataflow.UnsafeDeserializationQuery
import UnsafeDeserializationFlow::PathGraph
from UnsafeDeserializationFlow::PathNode source, UnsafeDeserializationFlow::PathNode sink
    where UnsafeDeserializationFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Memcached deserialization depends on a $@.", source.getNode(), "user-provided value"