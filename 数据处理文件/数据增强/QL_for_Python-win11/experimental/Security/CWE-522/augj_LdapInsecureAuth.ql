/**
 * @name Python Insecure LDAP Authentication
 * @description Detects insecure LDAP authentication patterns in Python code
 * @kind path-problem
 * @problem.severity error
 * @id py/insecure-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-522
 *       external/cwe/cwe-523
 */

// Import required analysis modules
import python  // Python language support
import experimental.semmle.python.security.LdapInsecureAuth  // LDAP security analysis capabilities
import LdapInsecureAuthFlow::PathGraph  // Data flow path graph for LDAP authentication

// Query definition to identify insecure LDAP authentication flows
from 
  LdapInsecureAuthFlow::PathNode startPoint, 
  LdapInsecureAuthFlow::PathNode endPoint
where 
  LdapInsecureAuthFlow::flowPath(startPoint, endPoint)
select 
  endPoint.getNode(), 
  startPoint, 
  endPoint, 
  "This LDAP host is authenticated insecurely."