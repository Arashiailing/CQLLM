import python

/**
 * @name CWE-20: Improper Input Validation (SSRF)
 * @description Detects potential SSRF vulnerabilities due to improper input validation
 */
from Call call, Argument arg, StringLiteral urlPart
where 
  call.getCallee().getName() = "requests.get" or 
  call.getCallee().getName() = "requests.post" or 
  call.getCallee().getName() = "urllib.request.urlopen"
  and arg.getArgumentIndex() = 0
  and urlPart.getValue() = arg.getArgument()
  and not (urlPart.getValue() like "http://%" or urlPart.getValue() like "https://%")
select urlPart, "Potential SSRF vulnerability: Unvalidated URL input used in HTTP request"