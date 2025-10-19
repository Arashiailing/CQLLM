/**
 * @name Code injection
 * @id py/xmlrpc
 * @tags security
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.3
 * @precision high
 */

import python
import experimental.semmle.python.security.dataflow.XmlRpcInjectionQuery

from XmlRpcInjectionFlow::PathNode source, XmlRpcInjectionFlow::PathNode sink
where XmlRpcInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "XML-RPC query parameter depends on a $@.", source.getNode(), "user-provided value"