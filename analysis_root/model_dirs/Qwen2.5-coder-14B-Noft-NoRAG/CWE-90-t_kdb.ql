import python

from FunctionCall fc, DataFlow::Node source, DataFlow::Node sink
where fc.getCallee().getName() = "ldap.search"
  and exists(DataFlow::Node node | node.asExpr() = fc.getArgument(1)
    and DataFlow::localFlow(source, node)
    and DataFlow::localFlow(node, sink)
    and source instanceof UserInput)
select sink, "This LDAP query is built from user-controlled sources, which is vulnerable to LDAP injection."