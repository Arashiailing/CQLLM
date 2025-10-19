import python
import semmle.code.java.HashFunctions

from Module m, CalledMethod cm
where
  m.getName() = "hashlib" and
  cm.getMethodName().getFullyQualifiedName() in ("hashlib.md5", "hashlib.sha1") and
  cm.getModule() = m
select cm, "Use of weak hash function for sensitive data"