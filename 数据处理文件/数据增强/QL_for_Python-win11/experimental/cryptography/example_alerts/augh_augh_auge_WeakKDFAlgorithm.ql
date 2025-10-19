/**
 * @name Weak KDF algorithm.
 * @description Identifies usage of unapproved key derivation function (KDF) algorithms. 
 * The following algorithms are considered secure and approved:
 * ["PBKDF2", "PBKDF2HMAC", "KBKDF", "KBKDFHMAC", "KBKDFCMAC", "CONCATKDF", "CONCATKDFHASH", "CONCATKDFHMAC"]
 * @assumption Input values (keys/passwords) are suitable for the chosen algorithm 
 * (for example, keys for KBKDF and passwords for PBKDF).
 * @kind problem
 * @id py/weak-kdf-algorithm
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

from KeyDerivationAlgorithm kdfInstance, string approvedKdfList
where 
  approvedKdfList = [
    "PBKDF2", "PBKDF2HMAC", "KBKDF", "KBKDFHMAC", "KBKDFCMAC", 
    "CONCATKDF", "CONCATKDFHASH", "CONCATKDFHMAC"
  ] and
  not kdfInstance.getKDFName() = approvedKdfList
select kdfInstance, "Use of unapproved, weak, or unknown key derivation algorithm or API."