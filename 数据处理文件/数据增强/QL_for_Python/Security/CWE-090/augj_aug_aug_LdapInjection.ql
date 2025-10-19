/**
 * @name LDAP query constructed from untrusted input sources
 * @description Identifies potential LDAP injection vulnerabilities where untrusted user input
 *              is incorporated into LDAP queries without adequate sanitization, enabling
 *              attackers to execute unauthorized LDAP operations.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @id py/ldap-injection
 * @tags security
 *       external/cwe/cwe-090
 */

// Essential security analysis modules for detecting LDAP injection vulnerabilities
import python
import semmle.python.security.dataflow.LdapInjectionQuery
import LdapInjectionFlow::PathGraph

from LdapInjectionFlow::PathNode originNode, LdapInjectionFlow::PathNode targetNode, string paramType
where
  // Verify data flow to the Distinguished Name (DN) parameter
  exists(string dnParam |
    dnParam = "DN" and
    LdapInjectionDnFlow::flowPath(originNode.asPathNode1(), targetNode.asPathNode1()) and 
    paramType = dnParam
  )
  or
  // Verify data flow to the filter parameter
  exists(string filterParam |
    filterParam = "filter" and
    LdapInjectionFilterFlow::flowPath(originNode.asPathNode2(), targetNode.asPathNode2()) and 
    paramType = filterParam
  )
select targetNode.getNode(), originNode, targetNode,
  "LDAP query parameter (" + paramType + ") is influenced by a $@.", originNode.getNode(),
  "user-provided value"