/**
 * @name Weak KDF algorithm.
 * @description Identifies the usage of unapproved key derivation function (KDF) algorithms.
 * Approved KDF algorithms must be one of the following:
 * ["PBKDF2", "PBKDF2HMAC", "KBKDF", "KBKDFHMAC", "KBKDFCMAC", "CONCATKDF", "CONCATKDFHASH", "CONCATKDFHMAC"]
 * @assumption The value being used to derive a key (either a key or a password) is appropriate for the algorithm (i.e., a key is used for KBKDF and a password for PBKDF).
 * @kind problem
 * @id py/weak-kdf-algorithm
 * @problem.severity error
 * @precision high
 */

import python  // Import Python library for analyzing Python code
import experimental.cryptography.Concepts  // Import experimental cryptography concepts for handling cryptographic operations

// This query identifies key derivation operations that use algorithms not in the approved list
from KeyDerivationAlgorithm unapprovedKDFOperation
where
  // The following algorithms are considered secure for key derivation
  not unapprovedKDFOperation.getKDFName() = [
    "PBKDF2", "PBKDF2HMAC", "KBKDF", "KBKDFHMAC", "KBKDFCMAC", "CONCATKDF", "CONCATKDFHASH",
    "CONCATKDFHMAC"
  ]
select unapprovedKDFOperation, "Usage of unapproved, weak, or unknown key derivation algorithm or API."  // Select operations that use unapproved, weak, or unknown key derivation function algorithms or APIs