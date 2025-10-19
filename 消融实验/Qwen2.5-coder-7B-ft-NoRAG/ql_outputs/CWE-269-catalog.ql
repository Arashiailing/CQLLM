/**
 * @name CWE-269: Improper Privilege Management
 * @id py/catalog
 */

import python
import semmle.python.security.dataflow.PrivilegeManagementQuery
import PrivilegeManagementFlow::PathGraph

from PrivilegeManagementFlow::PathNode source, PrivilegeManagementFlow::PathNode sink
where PrivilegeManagementFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Improper privilege management occurs here."