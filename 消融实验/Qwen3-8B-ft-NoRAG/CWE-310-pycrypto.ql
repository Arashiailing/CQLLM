import python
import security

from Call call, Argument arg
where call.get_name() in ("hashlib.md5", "hashlib.sha1", "hashlib.sha0", "hashlib.md4")
  and arg is security.SecuritySensitiveData
select call, "Weak sensitive data hashing detected using " + call.get_name()