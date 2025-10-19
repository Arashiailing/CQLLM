import py

/**
 * @name CWE-287: Improper Authentication
 * @description Detects improper authentication by checking for missing or insufficient identity verification in Python code.
 */
from MethodCall mc, StringLiteral username, StringLiteral password, BinaryOperation compare
where
  mc.getMethodName() = "authenticate" or
  mc.getMethodName() = "login" or
  mc.getMethodName() = "check_credentials"
  and
  compare.getOperator() = "=" and
  compare.getLeft() = username and
  compare.getRight() = password
  and
  mc.getArgument(0) = username and
  mc.getArgument(1) = password
  and
  not (mc.getQualifier() = "werkzeug.security" and mc.getMethodName() = "check_password_hash")
select mc, "Potential CWE-287: Improper Authentication - Direct password comparison without secure verification"