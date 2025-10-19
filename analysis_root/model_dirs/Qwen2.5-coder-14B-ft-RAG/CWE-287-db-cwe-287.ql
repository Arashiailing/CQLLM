/**
 * @name CWE-287: Improper Authentication
 * @description When an actor claims to have a given identity, the product does not prove or insufficiently proves that the claim is correct.
 * @kind problem
 * @problem.severity error
 * @security-severity 8.1
 * @precision high
 * @id py/db-cwe-287
 * @tags security
 *       external/cwe/cwe-287
 */

import python
import semmle.python.ApiGraphs

predicate insecureAuth(string authMechanism, Expr loginOp) {
  authMechanism in ["ldap", "ldaps"] and
  loginOp.(Call).getFunc().(Attribute).getName() = "simple_bind_s" and
  loginOp.(Call).getArg(0).(StringLiteral).getText() = authMechanism
}

predicate usesVulnerableAuthMechanism(Expr loginOp, string authMechanism) {
  authMechanism in ["ldap", "ldaps"] and
  (
    loginOp.(Call).getFunc().(Attribute).getName() = "simple_bind_s" and
    loginOp.(Call).getArg(0).(StringLiteral).getText() = authMechanism
    or
    api_call_with_location(loginOp, "ldap://*", _) and
    authMechanism = "ldap"
  )
}

predicate isUnverifiedConnection(Connection con) {
  con.getScope() instanceof Client and
  not con.getProtocol() = "ldaps" and
  not exists(con.(ApiClientConnection).getApiServer().getHost().(StringLiteral).getText() = _)
}

predicate isUsedForAuth(Connection con, Expr loginOp) {
  con.getConnectionExpr() = loginOp.getAnArg()
}

from Expr loginOp, Connection con, string authMechanism
where
  usesVulnerableAuthMechanism(loginOp, authMechanism) and
  isUnverifiedConnection(con) and
  isUsedForAuth(con, loginOp)
select loginOp,
  "Unverified connection established to " + authMechanism + "."