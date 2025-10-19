/**
* @name CWE-264: Permissions, Privileges,
    and Access Controls
*
@description Ensuring proper permissions
    and privileges f
    or system resources.
* @kind path-problem
*
@id py/security-groups
* @problem.severity warning
* @precision high
* @security-severity 4.0
*
@tags security * external/cwe/cwe-264
*/
import python
import semmle.python.security.authorization.AuthorizationQuery
from AuthorizationNode source, AuthorizationNode sink
    where AuthorizationFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Potential permission escalation detected.", source.getNode(), "user-supplied input"