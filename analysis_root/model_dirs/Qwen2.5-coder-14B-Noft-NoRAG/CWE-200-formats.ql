import python

/**
 * CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * Detects instances where sensitive information is logged in cleartext.
 */

class SensitiveInfoLogging extends Expr {
  SensitiveInfoLogging() {
    this instanceof CallExpr and
    this.getCallee().getName() = "log" and
    this.getArgument(0) instanceof StrLiteral and
    this.getArgument(0).getValue().matches(".*password.*|.*secret.*|.*key.*|.*token.*|.*credential.*")
  }
}

from SensitiveInfoLogging logCall
select logCall, "Sensitive information is logged in cleartext."