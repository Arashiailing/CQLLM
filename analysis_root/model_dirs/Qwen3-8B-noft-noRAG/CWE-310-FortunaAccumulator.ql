import python

from Call call
where call.getTarget().getName() in ("md5", "sha1", "sha")
  and call.getImportPath().getModule().getName() = "hashlib"
select call, "Use of weak hashing algorithm (MD5/SHA-1) for sensitive data."