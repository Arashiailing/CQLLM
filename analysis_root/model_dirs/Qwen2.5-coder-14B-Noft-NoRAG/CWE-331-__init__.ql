import python

/**
 * Query to detect CWE-331: Weak Sensitive Data Hashing
 * This query looks for instances where sensitive data is hashed using weak algorithms.
 */

from Call call, Function func
where call.getCallee() = func and
      func.getName() = "hashlib.md5" or
      func.getName() = "hashlib.sha1"
select call, "Sensitive data is hashed using a weak algorithm (md5 or sha1)."