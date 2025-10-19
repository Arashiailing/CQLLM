/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description Hashing sensitive information without proper salting or hashing algorithm can expose it to unauthorized actors.
 * @id py/hashers
 */

import python
import semmle.python.security.dataflow.HashingQuery

from HashingFlow::PathNode source, HashingFlow::PathNode sink
where HashingFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Sensitive information is hashed without proper salt or algorithm."