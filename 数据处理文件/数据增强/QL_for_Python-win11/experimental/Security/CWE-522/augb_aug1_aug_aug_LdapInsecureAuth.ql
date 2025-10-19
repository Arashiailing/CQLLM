/**
 * @name Python Insecure LDAP Authentication
 * @description Identifies LDAP authentication implementations missing critical security controls,
 *              which could lead to credential exposure or unauthorized system access.
 * @kind path-problem
 * @problem.severity error
 * @id py/insecure-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-522  // Insufficiently Protected Credentials
 *       external/cwe/cwe-523  // Unprotected Transport of Credentials
 */

// Core imports for LDAP vulnerability analysis
import python
import experimental.semmle.python.security.LdapInsecureAuth
import LdapInsecureAuthFlow::PathGraph

// Trace credential flow through insecure authentication paths
from LdapInsecureAuthFlow::PathNode credentialOrigin, LdapInsecureAuthFlow::PathNode vulnerableSink
where 
  // Verify existence of data flow path between credential source and vulnerable sink
  LdapInsecureAuthFlow::flowPath(credentialOrigin, vulnerableSink)
select 
  // Report the vulnerable sink location where insecure authentication occurs
  vulnerableSink.getNode(), 
  // Include complete flow path for vulnerability visualization
  credentialOrigin, vulnerableSink, 
  // Provide contextual security alert message
  "Insecure LDAP authentication detected for this host"