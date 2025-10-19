/**
 * @name Weak cryptographic hash functions
 * @description Detects the use of cryptographic hash functions that are considered weak or deprecated.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import necessary Python and cryptographic security analysis modules
import python
import experimental.cryptography.Concepts

// Identify weak cryptographic hash algorithm implementations in the codebase
from HashAlgorithm cryptoHash, string algorithmName, string securityAlert
where
  // Retrieve the name of the hash algorithm being used
  algorithmName = cryptoHash.getHashName() and
  // Filter out approved strong cryptographic hash algorithms
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate security alert message based on algorithm status
  (
    if algorithmName = unknownAlgorithm()
    then securityAlert = "Use of unrecognized hash algorithm."
    else securityAlert = "Use of unapproved hash algorithm or API: " + algorithmName + "."
  )
select cryptoHash, securityAlert