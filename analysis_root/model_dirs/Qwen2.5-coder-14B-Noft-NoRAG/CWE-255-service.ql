import python

/**
 * CWE-255: Hardcoded Credentials
 */
from CallExpr call, StringLiteral credential
where call.getCallee().getName() = "get_secret" and
      credential.getStringValue()!= ""
select call, "This call to get_secret includes a hardcoded credential."