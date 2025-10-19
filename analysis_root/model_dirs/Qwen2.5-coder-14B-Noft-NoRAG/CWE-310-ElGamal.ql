import python

/**
 * @name CWE-310: Weak Sensitive Data Hashing
 * @description Detects the use of weak hashing algorithms for sensitive data.
 * @id py/ElGamal
 */

from Call call, Function func
where func.getName() = "hashlib.md5" or func.getName() = "hashlib.sha1"
  and call.getCallee() = func
select call, "Weak hashing algorithm used for sensitive data: " + func.getName()