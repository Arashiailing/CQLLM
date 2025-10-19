import python
import experimental.cryptography.Concepts

from HashAlgorithm alg
where alg.getName() in ("md5", "sha1")
select alg, "Use of weak hashing algorithm " + alg.getName() + " for sensitive data"