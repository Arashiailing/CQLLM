import python

from Call call
where call.getCallee().getModule() = "hashlib" 
  and (call.getCallee().getName() = "md5" or call.getCallee().getName() = "sha1")
select call, "Weak hashing algorithm used for sensitive data (CWE-255)."