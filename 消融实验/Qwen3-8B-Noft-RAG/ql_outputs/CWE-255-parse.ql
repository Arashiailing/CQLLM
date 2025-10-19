/**
 * @name CWE CATEGORY: Credentials Management Errors
 * @id py/weak-sensitive-data-hashing
 */
import python
import semmle.python.security.dataflow.HashingQuery
import HashingFlow::PathGraph

from HashingFlow::PathNode source, HashingFlow::PathNode sink
where HashingFlow::flowPath(source, sink)
  and sink.getNode().getQualifiedName() = "hashlib.md5"
  and sink.getNode().getQualifiedName() = "hashlib.sha1"
select sink.getNode(), source, sink, "Weak sensitive data hashing detected using $@.", source.getNode(), "user-provided password"