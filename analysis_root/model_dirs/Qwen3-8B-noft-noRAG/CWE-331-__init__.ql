import python

from MethodCall mc
where 
  mc.getMethodName() = "md5" or 
  mc.getMethodName() = "sha1" or 
  mc.getMethodName() = "md5_file" or 
  mc.getMethodName() = "sha1_file"
  and mc.getModule().getName() = "hashlib"
select mc, "Usage of weak hash algorithm (CWE-331)"