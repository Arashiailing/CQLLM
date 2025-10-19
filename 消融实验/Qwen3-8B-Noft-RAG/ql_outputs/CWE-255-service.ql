/**
 * @name CWE CATEGORY: Credentials Management Errors
 * @id py/service
 */
import python
import semmle.python.security.dataflow.CredentialsManagementQuery
import CredentialsManagementFlow::PathGraph

from CredentialsManagementFlow::PathNode source, CredentialsManagementFlow::PathNode sink
where CredentialsManagementFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Credentials management issue detected involving a $@.", source.getNode(), "hardcoded credential"