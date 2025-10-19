/**
* @name CWE-264: Improper Access Control
*
@description Lack of proper access control mechanisms can lead to unauthorized access to system resources.
* @kind path-problem
* @problem.severity error
* @security-severity 8.0
* @precision high
*
@id py/preview
*
@tags security
*/
import python
import semmle.python.security.accesscontrol.AccessControlQuery
from AccessControlFlow::PathNode source, AccessControlFlow::PathNode sink
    where AccessControlFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Access control failure depends on a $@.", source.getNode(), "user-supplied input"