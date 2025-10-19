import python
import experimental.cryptography.Concepts

from HashAlgorithm alg
where alg.getName() in ("MD5", "SHA-1", "SHA-0", "MD2", "MD4")
select alg, "Use of weak hashing algorithm " + alg.getName()