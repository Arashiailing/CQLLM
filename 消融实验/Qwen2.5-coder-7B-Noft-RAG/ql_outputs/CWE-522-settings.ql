/**
* @name CWE-522: Insufficiently Protected Credentials
*
@description Storing credentials in plain text can lead to unauthorized access.
* @kind path-problem
* @problem.severity error
* @security-severity 8.8
* @precision high
*
@id py/settings
*
@tags security * external/cwe/cwe-522
*/
import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.security.dataflow.CleartextStorageQuery
from CleartextStorageFlow::PathNode source, CleartextStorageFlow::PathNode sink, string classification
    where CleartextStorageFlow::flowPath(source, sink)
    and classification = source.getNode().(Source).getClassification()
    select sink.getNode(), source, sink, "Credentials are stored in plain text.", source.getNode(), "credentials"