/**
* @name Cleartext Storage Query Vulnerability
* @kind path-problem
* @problem.severity error
* @security-severity 9.8
* @precision high
*
@id py/core-cwe-255
*
@tags security * external/cwe/cwe-255
*/
import python
import semmle.python.security.dataflow.CleartextStorageQuery
from CleartextStorageFlow::PathNode source, CleartextStorageFlow::PathNode sink
    where CleartextStorageFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Storing credentials in cleartext is highly insecure."