import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow

/**
 * @name CWE-287: Improper Authentication
 * @description When an actor claims to have a given identity, the product does not prove or insufficiently proves that the claim is correct.
 * @id py/omr-admin
 */

// Define source and sink predicates for authentication context
predicate isAuthenticationSource(DataFlow::Node node) {
  node instanceof AuthCredentialSource
}

predicate isAuthenticationSink(DataFlow::Node node) {
  node instanceof AuthVerificationSink
}

// Query to find paths from authentication sources to sinks
from DataFlow::PathNode source, DataFlow::PathNode sink
where DataFlow::flowPath(source, sink)
  and isAuthenticationSource(source.getNode())
  and isAuthenticationSink(sink.getNode())
select sink.getNode(), source, sink, "Improper authentication: Credential used without verification", source.getNode(), "user-provided credential"