import python

from Call import Call
where Call.get_module() = "hashlib" and (Call.get_method().getName() = "md5" or Call.get_method().getName() = "sha1")
select Call, "This uses an insecure hashing algorithm (MD5 or SHA-1), which is vulnerable to collision attacks."