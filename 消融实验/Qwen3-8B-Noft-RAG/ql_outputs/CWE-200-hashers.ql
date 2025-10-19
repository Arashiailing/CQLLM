/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @id py/hashers
 */
import python
import semmle.python.security.dataflow.HashingQuery
import HashingFlow::PathGraph

from HashingFlow::PathNode source, HashingFlow::PathNode sink
where HashingFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Sensitive data is hashed using a weak algorithm.", source.getNode(), "weak hashing function"