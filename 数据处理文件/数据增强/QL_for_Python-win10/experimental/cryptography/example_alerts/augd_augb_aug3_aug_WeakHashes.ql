/**
 * @name Weak cryptographic hash algorithms
 * @description Detects usage of cryptographic hash functions that are either
 *              deprecated or considered insecure for security-sensitive applications.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import necessary Python libraries and cryptographic analysis components
import python
import experimental.cryptography.Concepts

// Find cryptographic hash operations using weak or non-approved algorithms
from HashAlgorithm cryptoHash, string hashAlgorithmName, string securityWarning
where
  // Retrieve the algorithm name from the cryptographic hash operation
  hashAlgorithmName = cryptoHash.getHashName() and
  // Filter out strong, approved cryptographic hash algorithms
  not hashAlgorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Determine the appropriate security warning based on algorithm recognition
  (
    // Scenario: Algorithm is identified but not approved
    hashAlgorithmName != "" and
    securityWarning = "Detected unapproved hash algorithm or API " + hashAlgorithmName + "."
  )
  or
  (
    // Scenario: Algorithm cannot be identified
    hashAlgorithmName = "" and
    securityWarning = "Detected unrecognized hash algorithm."
  )
select cryptoHash, securityWarning