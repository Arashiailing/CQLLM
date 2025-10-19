import python

/**
 * CWE-287: Improper Authentication
 * This query detects instances where authentication is not properly verified.
 */

class PamAuthorizationQuery extends Query {
  /**
   * Finds calls to pam_authenticate that do not check the return value.
   */
  pam_authenticate_without_check() {
    from CallExpr call, Argument arg
    where call.getCallee().getName() = "pam_authenticate"
      and call.getArgument(0) = arg
      and not exists(call.getNextStmt().(ExprStmt).getExpr().(CallExpr).getCallee().getName() = "check_auth_result")
    select call, "The call to pam_authenticate does not check the return value."
  }
}