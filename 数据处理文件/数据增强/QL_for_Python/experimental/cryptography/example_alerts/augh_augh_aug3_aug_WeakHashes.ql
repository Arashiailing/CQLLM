/**
 * @name Insecure cryptographic hash function usage
 * @description Detects applications using cryptographic hash algorithms that are
 *              either not approved or known to be weak for security-sensitive operations.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import necessary Python language constructs and cryptographic analysis definitions
import python
import experimental.cryptography.Concepts

// Identify cryptographic hash operations that use weak or unapproved algorithms
from HashAlgorithm cryptoHashOperation, string hashAlgorithmName, string securityWarning
where
  // Extract the algorithm name from the hash operation
  hashAlgorithmName = cryptoHashOperation.getHashName() and
  // Filter out strong, approved hash algorithms
  not hashAlgorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate security warning based on the detected algorithm
  (
    // Handle recognized but unapproved algorithms
    hashAlgorithmName != "" and
    securityWarning = "Use of unapproved hash algorithm or API " + hashAlgorithmName + "."
  )
  or
  (
    // Handle unrecognized or empty algorithm identifiers
    hashAlgorithmName = "" and
    securityWarning = "Use of unrecognized hash algorithm."
  )
select cryptoHashOperation, securityWarning