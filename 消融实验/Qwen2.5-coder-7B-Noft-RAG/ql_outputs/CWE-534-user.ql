/**
* @name CWE-534: DEPRECATED: Information Exposure Through Debug Log Files
*
@description nan
*
@id py/user
*/
import python
import semmle.python.security.dataflow.DebugLogQuery
from DebugLogFlow::PathNode source, DebugLogFlow::PathNode sink
    where DebugLogFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Sensitive information is being logged without encryption."