import python

/**
 * This query detects CWE-287: Improper Authentication.
 * It looks for cases where user authentication is not properly verified.
 */

class ImproperAuthentication extends DataFlow::Node {
  ImproperAuthentication() {
    this instanceof CallExpr and
    this.getCallee().getName() = "authenticate" and
    not this.getAnArgument(0) instanceof SecureAuthentication
  }
}

class SecureAuthentication extends Expr {
  SecureAuthentication() {
    this instanceof CallExpr and
    this.getCallee().getName() = "verifyCredentials"
  }
}

from ImproperAuthentication auth
select auth, "This authentication call does not verify the user's identity properly."