/**
* @name CWE-362: CleartextStorageQuery
*
@description Storing sensitive information in cleartext can expose it to unauthorized access.
* @kind problem
* @problem.severity error
* @security-severity 7.8
* @precision high
*
@id py/cleartext-storage-query
*
@tags security
*/
import python
import semmle.python.security.dataflow.CleartextStorageQuery
import CleartextStorageFlow::PathGraph
from CleartextStorageFlow::PathNode source, CleartextStorageFlow::PathNode sink
    where CleartextStorageFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Storing sensitive information in cleartext."