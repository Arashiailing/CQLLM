import python

from FunctionCall import FunctionCall
where FunctionCall.name in ("hashlib.md5", "hashlib.sha1", "hashlib.sha224", "hashlib.sha384", "hashlib.sha512")
select FunctionCall, "Use of weak cryptographic hash function"