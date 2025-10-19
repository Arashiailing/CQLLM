import python

/**
 * This query detects the use of weak hashing algorithms for sensitive data.
 * CWE-310: Use of Weak Hashing Algorithm
 */
from CallExpr call, Function function
where call.getCallee() = function and
      function.getName() = "hashlib.md5" or
      function.getName() = "hashlib.sha1"
select call, "This call uses a weak hashing algorithm (MD5 or SHA1) for sensitive data."