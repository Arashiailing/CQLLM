/**
* @name CWE-522: Insufficiently Protected Credentials
*
@description Storing credentials in cleartext is insecure because they can be intercepted.
* @kind problem
* @problem.severity error
* @security-severity 9.0
* @precision high
*
@id py/cleartext-storage-query
*
@tags security * external/cwe/cwe-522
*/
import python
import semmle.python.security.dataflow.CleartextStorageQuery
import CleartextStorageFlow::PathGraph
from CleartextStorageFlow::PathNode source, CleartextStorageFlow::PathNode sink
    where CleartextStorageFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Credentials are stored in cleartext."