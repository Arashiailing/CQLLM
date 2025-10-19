import python

/**
 * @name CWE-287: Improper Authentication
 * @description Detects improper authentication by checking for missing password validation
 * @id py/gpgi
 */
from AuthenticationMechanism auth
where auth.hasNoPasswordValidation
select auth, "This authentication mechanism lacks proper password validation, potentially allowing unauthorized access (CWE-287)."