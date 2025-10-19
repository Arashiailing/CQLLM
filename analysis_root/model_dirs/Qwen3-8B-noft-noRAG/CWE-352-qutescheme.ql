import python

/**
 * @name ReflectedXssQuery
 * @description Detects potential reflected XSS vulnerabilities by identifying unsafe string concatenations involving user input from HTTP requests.
 */
from CallExpr getParamCall, StringConcatenation unsafeConcat, CallExpr outputCall
where 
  getParamCall.getMethodName() = "get" and 
  getParamCall.getCallee().getName() = "args" and 
  unsafeConcat.getKinds() = StringConcatenationKind.STRING_CONCATENATION and 
  exists(unsafeConcat.getStrings()) and 
  exists(unsafeConcat.getStrings().filter(s -> s.isLiteral())) and 
  outputCall.getMethodName() in ("send", "write", "render_template") and 
  outputCall.getArg(0).isReferenceTo(unsafeConcat)
select outputCall.getLocation(), "Potential reflected XSS vulnerability detected: unsafe string concatenation with user input used in HTTP response."