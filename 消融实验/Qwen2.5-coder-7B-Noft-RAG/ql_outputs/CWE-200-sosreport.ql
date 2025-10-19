/**
* @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
*
@description Storing sensitive information in cleartext can expose it to unauthorized actors.
* @kind path-problem
* @problem.severity warning
* @security-severity 8.0
* @precision high
*
@id py/sosreport
*
@tags security * external/cwe/cwe-200
*/
import python
import semmle.python.security.dataflow.CleartextStorageQuery
import CleartextStorageFlow::PathGraph
from CleartextStorageFlow::PathNode source, CleartextStorageFlow::PathNode sink
    where CleartextStorageFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Sensitive information is stored in cleartext."