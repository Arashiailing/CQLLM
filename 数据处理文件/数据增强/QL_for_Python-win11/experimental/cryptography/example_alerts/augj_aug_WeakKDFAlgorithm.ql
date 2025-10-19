/**
 * @name Weak KDF algorithm.
 * @description Identifies Python code that uses weak or unapproved key derivation functions (KDFs).
 *              Only the following KDF algorithms are considered approved:
 *              ["PBKDF2", "PBKDF2HMAC", "KBKDF", "KBKDFHMAC", "KBKDFCMAC", "CONCATKDF", "CONCATKDFHASH", "CONCATKDFHMAC"]
 * @assumption The input value (key or password) is appropriate for the algorithm being used
 *             (e.g., a key for KBKDF and a password for PBKDF).
 * @kind problem
 * @id py/weak-kdf-algorithm
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify key derivation operations using non-approved algorithms
from KeyDerivationAlgorithm weakKDFOperation
where not weakKDFOperation.getKDFName() = [
    "PBKDF2", "PBKDF2HMAC", "KBKDF", "KBKDFHMAC", "KBKDFCMAC", 
    "CONCATKDF", "CONCATKDFHASH", "CONCATKDFHMAC"
  ]
select weakKDFOperation, "Use of unapproved, weak, or unknown key derivation algorithm or API."