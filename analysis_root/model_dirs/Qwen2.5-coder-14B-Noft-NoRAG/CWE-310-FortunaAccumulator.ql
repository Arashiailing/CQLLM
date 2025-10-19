import python

/**
 * @name CWE-310: Weak Sensitive Data Hashing
 * @description This query detects the use of weak hash functions for sensitive data in Python.
 * @id py/FortunaAccumulator
 */

from CallExpr call, Function func
where func.getName() = "hashlib.md5" or func.getName() = "hashlib.sha1"
  and call.getArgument(0).getType().toString() = "str"
select call, "Weak hash function used for sensitive data."