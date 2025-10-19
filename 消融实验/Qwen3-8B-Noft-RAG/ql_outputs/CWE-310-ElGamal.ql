/**
 * @name CWE-310: Weak Sensitive Data Hashing
 * @id py/cwe-310-weak-hash
 */
import python
import experimental.cryptography.Concepts

from HashAlgorithm alg
where alg.getName() in ("MD5", "SHA-1")
select alg, "Weak hashing algorithm used for sensitive data"