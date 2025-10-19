import python

/**
 * CWE-522: Insufficiently Protected Credentials
 * This query detects instances where credentials are stored in cleartext.
 */

from Call call, Variable credVar, StringLiteral credValue
where call.getCallee().getName() = "open" and
      call.getArgument(0) = credVar and
      credVar.getDefiningExpr() instanceof StringLiteral and
      credValue = credVar.getDefiningExpr().asString()
select call, "Credentials are stored in cleartext: " + credValue