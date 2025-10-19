/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 5.0
 * @precision medium
 * @id py/store_invite_servlet
 * @tags security
 *       external/cwe/cwe-400
 */

import python
import semmle.python.security.dataflow.StoreInviteServletQuery
import StoreInviteServletFlow::PathGraph

from StoreInviteServletFlow::PathNode source, StoreInviteServletFlow::PathNode sink
where StoreInviteServletFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Store Invite Servlet makes use of an untrusted request parameter."