/**
* @name CWE-255: Weak Sensitive Data Hashing
* @category Credentials Management Errors
*
@description Detects instances
    where sensitive data is hashed using weak algorithms.
*
@id py/weak-sensitive-data-hashing
*/
import python
import semmle.python.security.dataflow.SensitiveDataHashingQuery predicate hasWeakHashing(string algorithm) { algorithm in {"md5", "sha1", "sha224"} }
from SensitiveDataHashingFlow::PathNode source, SensitiveDataHashingFlow::PathNode sink
    where SensitiveDataHashingFlow::flowPath(source, sink)
    and hasWeakHashing(sink.getNode())
    select sink.getNode(), source, sink, "Sensitive data is hashed using a weak algorithm."