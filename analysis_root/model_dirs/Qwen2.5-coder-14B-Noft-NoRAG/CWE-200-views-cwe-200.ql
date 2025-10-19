import python

/**
 * CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 */
from CallExpr call, StrLiteral str
where call.getCallee().getName() = "print" and
      str.getValue() =~ /.*password.*|.*secret.*|.*token.*|.*key.*|.*credential.*/i
select call, "This print statement may expose sensitive information."