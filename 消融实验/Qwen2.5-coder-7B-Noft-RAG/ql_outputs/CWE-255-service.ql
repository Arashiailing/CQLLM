/**
* @name CWE-255: Improper Authorization
*
@description Improper authorization may allow unauthorized access to sensitive operations.
*
@id py/improper-authorization
*
@tags security
*/
import python
import semmle.python.security.authorization.AuthorizationCheck
from AuthorizationCheck check
    where check.isImproper()
    select check, "Potential improper authorization issue."