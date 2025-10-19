/**
 * @name Weak cryptographic hash algorithms
 * @description Identifies the use of cryptographic hash functions that are either
 *              deprecated or considered insecure for security-sensitive applications.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import necessary Python modules and cryptographic analysis components
import python
import experimental.cryptography.Concepts

// Identify hash function implementations that use weak or deprecated cryptographic algorithms
from HashAlgorithm cryptoHash, string hashAlgorithmName, string securityWarning
where
  // Extract the algorithm identifier from the hash function implementation
  hashAlgorithmName = cryptoHash.getHashName() and
  // Exclude implementations that use secure, approved hash algorithms (SHA256, SHA384, SHA512)
  not hashAlgorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate security warning based on algorithm recognition status
  (
    // Case: Algorithm is identified but not approved for security-sensitive applications
    hashAlgorithmName != "" and
    securityWarning = "Detected usage of unapproved hash algorithm or API: " + hashAlgorithmName + "."
  )
  or
  (
    // Case: Algorithm cannot be identified or recognized
    hashAlgorithmName = "" and
    securityWarning = "Detected usage of unrecognized hash algorithm."
  )
select cryptoHash, securityWarning