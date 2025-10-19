/**
 * @name Weak cryptographic hash algorithms
 * @description Identifies the use of cryptographic hash functions that are
 *              either deprecated or deemed insecure for security-critical applications.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required Python modules and cryptographic analysis utilities
import python
import experimental.cryptography.Concepts

// Identify hash function implementations utilizing weak or deprecated cryptographic algorithms
from HashAlgorithm cryptoHash, string hashAlgorithmName, string securityWarning
where
  // Retrieve the algorithm name from the hash function implementation
  hashAlgorithmName = cryptoHash.getHashName() and
  // Exclude strong, approved hash algorithms from our detection
  not hashAlgorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate security warning based on algorithm recognition status
  (
    // Case: Algorithm is identified but not approved for security-sensitive contexts
    hashAlgorithmName != "" and
    securityWarning = "Detected usage of unapproved hash algorithm or API: " + hashAlgorithmName + "."
  )
  or
  (
    // Case: Algorithm cannot be identified or recognized by the analysis
    hashAlgorithmName = "" and
    securityWarning = "Detected usage of unrecognized hash algorithm."
  )
select cryptoHash, securityWarning