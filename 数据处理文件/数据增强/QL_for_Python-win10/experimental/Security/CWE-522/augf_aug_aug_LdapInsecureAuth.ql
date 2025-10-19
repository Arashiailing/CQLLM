/**
 * @name Python Insecure LDAP Authentication
 * @description Detects insecure LDAP authentication configurations lacking proper security controls
 * @kind path-problem
 * @problem.severity error
 * @id py/insecure-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-522
 *       external/cwe/cwe-523
 */

// Required modules for LDAP vulnerability analysis
import python
import experimental.semmle.python.security.LdapInsecureAuth
import LdapInsecureAuthFlow::PathGraph

// Identify vulnerable authentication paths
from LdapInsecureAuthFlow::PathNode sourceNode, LdapInsecureAuthFlow::PathNode targetNode
// Verify security flaw exists between source and target
where LdapInsecureAuthFlow::flowPath(sourceNode, targetNode)
// Report findings with path context
select targetNode.getNode(), sourceNode, targetNode, "Insecure LDAP authentication detected for this host"