/**
 * @name CWE CATEGORY: Credentials Management Errors
 * @description Storage of credentials in cleartext can lead to unauthorized access.
 * @id py/core-cwe-255
 */
import python
import semmle.python.security.dataflow.CredentialsManagementQuery

from DataFlow::Node source, DataFlow::Node sink
where CredentialsManagementQuery::isCleartextStorage(source)
select sink.getNode(), source, sink, "Credentials are stored in cleartext."