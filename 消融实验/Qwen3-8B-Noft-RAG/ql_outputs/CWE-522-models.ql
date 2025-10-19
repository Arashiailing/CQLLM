/** @name CWE-522: Insufficiently Protected Credentials */
import python
import semmle.python.security.dataflow.SensitiveDataFlow

from SensitiveDataFlow::PathNode source, SensitiveDataFlow::PathNode sink
where SensitiveDataFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Credentials stored in cleartext", source.getNode(), "sensitive data"