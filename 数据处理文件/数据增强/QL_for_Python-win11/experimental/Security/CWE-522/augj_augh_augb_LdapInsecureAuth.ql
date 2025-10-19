/**
 * @name Python Insecure LDAP Authentication
 * @description Detects insecure LDAP authentication patterns in Python applications
 * @kind path-problem
 * @problem.severity error
 * @id py/insecure-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-522
 *       external/cwe/cwe-523
 */

// Import core analysis modules
import python  // Python language support
import experimental.semmle.python.security.LdapInsecureAuth  // LDAP security analysis
import LdapInsecureAuthFlow::PathGraph  // Path tracking for LDAP flows

// Identify vulnerable data flow paths between source and sink
from LdapInsecureAuthFlow::PathNode ldapSource, LdapInsecureAuthFlow::PathNode ldapSink
where LdapInsecureAuthFlow::flowPath(ldapSource, ldapSink)

// Report findings with complete path context
select ldapSink.getNode(), ldapSource, ldapSink, "Insecure LDAP authentication detected at this host."