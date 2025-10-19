import py

from Call call
where call.getFunction().getModule() = "hashlib"
  and call.getFunction().getName() in ("md5", "sha1", "sha224", "sha384", "sha512")
select call, "Weak sensitive data hashing detected using weak algorithm."