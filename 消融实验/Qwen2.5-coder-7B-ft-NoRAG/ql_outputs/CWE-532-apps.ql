/**
 * @name CWE-532: Insertion of Sensitive Information into Log File
 * @id py/cleartext-logging-query
 */

import python
import semmle.python.security.dataflow.CleartextLoggingQuery

from CleartextLoggingFlow::PathNode source, CleartextLoggingFlow::PathNode sink, string classification
where
  CleartextLoggingFlow::flowPath(source, sink)
  and classification = source.getNode().(Source).getClassification()
select sink.getNode(), source, sink, "Sensitive information is logged without encryption or hashing."