/**
 * @name CWE-264: Permissions, Privileges, and Access Controls
 * @description Insufficient permissions can lead to privilege escalation attacks.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/permissions-insufficiency
 * @tags security
 *       external/cwe/cwe-264
 */

import python
import semmle.python.security.dataflow.AccessControlQuery
import AccessControlFlow::PathGraph

from AccessControlFlow::PathNode source, AccessControlFlow::PathNode sink
where AccessControlFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Insufficient permissions granted to $@.", source.getNode(), "untrusted input"