/**
 * @name Weak cryptographic hash algorithms
 * @description Identifies cryptographic hash functions that are either not suitable
 *              for security applications or are considered cryptographically weak.
 *              This query helps discover potential security issues in cryptographic code.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required modules for Python analysis and cryptographic security
import python
import experimental.cryptography.Concepts

// Query to detect weak cryptographic hash operations and generate security alerts
from HashAlgorithm cryptoHashOp, string hashAlgoName, string securityAlert
where
  // Extract the hash algorithm name from the cryptographic operation
  hashAlgoName = cryptoHashOp.getHashName() and
  // Check if the algorithm is not in the approved list of strong hash functions
  not hashAlgoName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate alert message based on whether the algorithm is recognized
  (
    // Handle unrecognized algorithms
    hashAlgoName = unknownAlgorithm() and
    securityAlert = "Use of unrecognized cryptographic hash algorithm."
    or
    // Handle recognized but unapproved algorithms
    not hashAlgoName = unknownAlgorithm() and
    securityAlert = "Use of unapproved cryptographic hash algorithm or API: " + hashAlgoName + "."
  )
// Output the cryptographic hash operation and corresponding security alert
select cryptoHashOp, securityAlert