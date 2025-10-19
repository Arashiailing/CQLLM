/**
 * @name Weak Key Derivation Function (KDF) Algorithm Detection
 * @description Identifies usage of unapproved KDF algorithms. Approved algorithms must be:
 *  ["PBKDF2", "PBKDF2HMAC", "KBKDF", "KBKDFHMAC", "KBKDFCMAC", "CONCATKDF", "CONCATKDFHASH", "CONCATKDFHMAC"]
 * @assumption The input value (key or password) is appropriate for the selected algorithm:
 *  - Keys must be used with KBKDF variants
 *  - Passwords must be used with PBKDF2 variants
 * @kind problem
 * @id py/weak-kdf-algorithm
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

from KeyDerivationAlgorithm kdfOperation
where
  not kdfOperation.getKDFName() = [
    "PBKDF2", "PBKDF2HMAC", "KBKDF", "KBKDFHMAC", "KBKDFCMAC", 
    "CONCATKDF", "CONCATKDFHASH", "CONCATKDFHMAC"
  ]
select kdfOperation, "Detected usage of unapproved, weak, or unknown key derivation algorithm or API."