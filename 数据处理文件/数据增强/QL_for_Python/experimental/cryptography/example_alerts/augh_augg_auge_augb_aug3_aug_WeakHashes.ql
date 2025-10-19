/**
 * @name Weak cryptographic hash algorithms
 * @description Detects usage of cryptographic hash functions that are either
 *              deprecated or considered insecure for security-sensitive contexts.
 *              This query identifies hash algorithms that are not part of the
 *              approved strong algorithm set (SHA256, SHA384, SHA512) or cannot
 *              be recognized by the analysis.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required Python modules and cryptographic analysis components
import python
import experimental.cryptography.Concepts

// Find cryptographic hash operations utilizing weak or non-approved algorithms
from HashAlgorithm cryptoHashOperation, string hashAlgorithmName, string securityAlert
where
  // Retrieve the name of the hash algorithm being used
  hashAlgorithmName = cryptoHashOperation.getHashName() and
  // Filter out strong, approved hash algorithms from our detection
  not hashAlgorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Construct appropriate security alert based on algorithm recognition
  (
    // Handle recognized but unapproved algorithms
    hashAlgorithmName != "" and
    securityAlert = "Use of unapproved hash algorithm or API " + hashAlgorithmName + "."
    or
    // Handle unrecognized algorithms
    hashAlgorithmName = "" and
    securityAlert = "Use of unrecognized hash algorithm."
  )
select cryptoHashOperation, securityAlert