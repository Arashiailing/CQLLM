import python

/**
 * This query detects potential instances of CWE-918: Server-Side Request Forgery (SSRF)
 * in Python code. It looks for cases where a network request is made to a URL that
 * is partially user-controlled.
 */

from Call call, StringLiteral url, Expr userControlledInput
where call.getCallee().getName() = "requests.get" and
      call.getArgument(0) = url and
      url.hasSubString(userControlledInput)
select call, "Potential SSRF vulnerability detected: User-controlled input is used in the URL of a network request."