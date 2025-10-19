/**
* @name CWE-310: Weak Sensitive Data Hashing
* @category Cryptographic Issues
*
@description Detects the use of weak hashing functions f
    or sensitive data.
*
@id py/FortunaAccumulator
*/
import python
import experimental.cryptography.Concepts
from HashAlgorithm alg
    where alg.getName() in {"MD5", "SHA-1"}
    select alg, "Use of weak hashing function " + alg.getName()