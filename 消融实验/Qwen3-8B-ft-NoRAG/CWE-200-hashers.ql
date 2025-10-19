import py

from Call call
where call.getQualifiedName() in ("hashlib.md5", "hashlib.sha1", "hashlib.sha224", "hashlib.sha384", "hashlib.sha512")
select call, "Weak sensitive data hashing detected using insecure algorithm."