import python

/**
 * A query to detect CWE-863: Incorrect Authorization in Python code.
 * This query looks for functions that perform authorization checks but do not correctly implement them.
 */

from Function func, Call call, Variable var
where
  // Check if the function is related to authorization
  func.getName() = "check_authorization" and
  // Check if the function calls another function that might be related to authorization
  call.getCallee().getName() = "is_authorized" and
  // Check if the function does not correctly implement the authorization check
  not (exists(Return ret | ret.getEnclosingFunction() = func and ret.getResult() = var))
select
  func, 
  "This function performs an authorization check but does not correctly implement it."