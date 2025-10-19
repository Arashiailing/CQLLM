/**
 * @name Weak cryptographic hash algorithms
 * @description Detects usage of weak or unapproved cryptographic hash functions
 *              that should not be used in security-sensitive contexts.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import necessary Python libraries and cryptographic analysis components
import python
import experimental.cryptography.Concepts

// Query to find cryptographic hash operations using weak algorithms
from HashAlgorithm hashFunc, string algorithmName, string warningMsg
where
  // Retrieve the algorithm name from the hash function
  algorithmName = hashFunc.getHashName() and
  // Filter out strong, approved hash algorithms (SHA-2 family)
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Determine warning message based on algorithm recognition status
  (
    // Handle recognized but unapproved algorithms
    algorithmName != "" and
    warningMsg = "Use of unapproved hash algorithm or API " + algorithmName + "."
  )
  or
  (
    // Handle unrecognized algorithms
    algorithmName = "" and
    warningMsg = "Use of unrecognized hash algorithm."
  )
select hashFunc, warningMsg