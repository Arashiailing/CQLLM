import python
import semmle.code.cpp.dataflow.DataFlow

/**
 * @name RCE
 * @id py/__init__
 */
from Call c
where
  c.getModule() = "hashlib" and
  (c.getMethodName() = "md5" or c.getMethodName() = "sha1")
select c, "Use of weak hashing algorithm detected (MD5/SHA-1)"