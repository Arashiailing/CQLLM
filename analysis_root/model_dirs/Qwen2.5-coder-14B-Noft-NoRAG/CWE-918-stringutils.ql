import python

/**
 * Detects CWE-918: Server-Side Request Forgery (SSRF)
 * Partial server-side request forgery. Making a network request to a URL
 * that is partially user-controlled allows for request forgery attacks.
 * The web server receives a URL or similar request from an upstream component
 * and retrieves the contents of this URL, but it does not sufficiently ensure
 * that the request is being sent to the expected destination.
 */

from Call call, Argument arg
where call.getCallee().getName() = "urlopen" and
      arg = call.getArgument(0) and
      arg instanceof StringLiteral
select arg, "This call to urlopen may be vulnerable to SSRF as it uses a user-controlled URL."