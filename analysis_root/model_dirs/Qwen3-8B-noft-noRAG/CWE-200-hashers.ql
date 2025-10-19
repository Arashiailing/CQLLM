import py

from PyFunctionCall call
where call.get_name() = "hashlib.md5" or 
      call.get_name() = "hashlib.sha1" or 
      call.get_name() = "hashlib.sha" and call.get_argument(0).getValue().toString() = "1"
select call, "Use of weak hashing algorithm detected (CWE-200)"