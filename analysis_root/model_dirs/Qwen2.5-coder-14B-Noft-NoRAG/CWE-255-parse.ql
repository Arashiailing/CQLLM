import python

/**
 * This query detects the use of weak hashing algorithms for sensitive data,
 * which is a common vulnerability related to CWE-255.
 */

from CallExpr call, Function func
where call.getCallee() = func and
      func.getName() = "hashlib.md5" or
      func.getName() = "hashlib.sha1" or
      func.getName() = "hashlib.sha224" or
      func.getName() = "hashlib.sha512"
select call, "Weak hashing algorithm used for sensitive data: " + func.getName()