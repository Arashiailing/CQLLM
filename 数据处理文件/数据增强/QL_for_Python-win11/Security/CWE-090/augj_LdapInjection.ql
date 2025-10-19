/**
 * @name LDAP query built from user-controlled sources
 * @description Detects LDAP queries constructed from user-supplied input, which could allow
 *              attackers to inject malicious LDAP commands through crafted input.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @id py/ldap-injection
 * @tags security
 *       external/cwe/cwe-090
 */

import python
import semmle.python.security.dataflow.LdapInjectionQuery
import LdapInjectionFlow::PathGraph

from LdapInjectionFlow::PathNode injectionSource, LdapInjectionFlow::PathNode injectionSink, string paramType
where 
  (
    // Check for data flow paths in DN parameters
    LdapInjectionDnFlow::flowPath(injectionSource.asPathNode1(), injectionSink.asPathNode1()) and
    paramType = "DN"
  )
  or
  (
    // Check for data flow paths in filter parameters
    LdapInjectionFilterFlow::flowPath(injectionSource.asPathNode2(), injectionSink.asPathNode2()) and
    paramType = "filter"
  )
select injectionSink.getNode(), injectionSource, injectionSink,
  "LDAP query parameter (" + paramType + ") depends on a $@.", injectionSource.getNode(),
  "user-provided value"