import python

/**
 * @name CWE-284: CleartextStorage
 * @description Detects potential cleartext storage of sensitive data.
 */
from StringLiteral sl, CallExpr ce
where sl.getString().matches(".*(?:password|secret|key|token|cred).*") and 
      (ce.getMethodName() = "write" or 
       ce.getMethodName() = "execute" or 
       ce.getMethodName() = "info" or 
       ce.getMethodName() = "log")
select ce, "Potential cleartext storage of sensitive data."