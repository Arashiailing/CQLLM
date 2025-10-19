/**
 * @name Weak KDF algorithm.
 * @description Detects the use of unapproved key derivation function (KDF) algorithms. 
 * Approved algorithms must be one of: 
 * ["PBKDF2", "PBKDF2HMAC", "KBKDF", "KBKDFHMAC", "KBKDFCMAC", "CONCATKDF", "CONCATKDFHASH", "CONCATKDFHMAC"]
 * @assumption The input value (key/password) is appropriate for the selected algorithm 
 * (e.g., keys used for KBKDF and passwords for PBKDF).
 * @kind problem
 * @id py/weak-kdf-algorithm
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

from KeyDerivationAlgorithm weakKdfInstance, string approvedAlgorithms
where 
  approvedAlgorithms = [
    "PBKDF2", "PBKDF2HMAC", "KBKDF", "KBKDFHMAC", "KBKDFCMAC", 
    "CONCATKDF", "CONCATKDFHASH", "CONCATKDFHMAC"
  ] and
  not weakKdfInstance.getKDFName() = approvedAlgorithms
select weakKdfInstance, "Use of unapproved, weak, or unknown key derivation algorithm or API."