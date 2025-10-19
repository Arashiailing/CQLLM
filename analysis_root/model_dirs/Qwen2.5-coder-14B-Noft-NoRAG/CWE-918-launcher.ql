import python

/**
 * Detects CWE-918: Server-Side Request Forgery (SSRF)
 * This query looks for cases where a URL or similar request is partially user-controlled
 * and is used to make a network request.
 */

from CallExpr call, Arg arg, StringLiteral literal, Identifier id
where call.getCallee().getName() = "requests.get" and
      arg = call.getArgument(0) and
      arg = literal or
      arg = id and
      id.getAConstString() = null
select call, "Potential SSRF vulnerability detected: User-controlled URL in network request."