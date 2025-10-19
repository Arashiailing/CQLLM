import python

/**
 * CWE-310: Weak Sensitive Data Hashing
 * This query detects the use of weak hashing algorithms for sensitive data.
 */

from Call call
where call.getCallee().getName() = "hashlib.md5" or
      call.getCallee().getName() = "hashlib.sha1" or
      call.getCallee().getName() = "hashlib.sha224"
select call, "This call uses a weak hashing algorithm for sensitive data."