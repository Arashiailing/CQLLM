/**
 * @name CWE-532: Insertion of Sensitive Information into Log File
 * @description The product writes sensitive information to a log file.
 * @id py/checks
 */

import python
import semmle.python.security.dataflow.CleartextLoggingQuery

from CleartextLoggingFlow::PathNode source, CleartextLoggingFlow::PathNode sink, string classification
where CleartextLoggingFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Sensitive information is logged in plain text."