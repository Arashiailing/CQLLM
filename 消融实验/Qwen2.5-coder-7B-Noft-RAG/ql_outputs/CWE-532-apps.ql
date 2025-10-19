/**
* @name CWE-532: Insertion of Sensitive Information into Log File
*
@description The product writes sensitive information to a log file.
*
@id py/cleartext-log-sensitivity
*/
import python
import semmle.python.security.dataflow.CleartextLoggingQuery
from CleartextLoggingFlow::PathNode source, CleartextLoggingFlow::PathNode sink, string classification
    where CleartextLoggingFlow::flowPath(source, sink)
    and classification = source.getNode().(Source).getClassification()
    select sink.getNode(), source, sink, "Sensitive information is logged in plain text.", source.getNode(), "sensitive data (" + classification + ")"