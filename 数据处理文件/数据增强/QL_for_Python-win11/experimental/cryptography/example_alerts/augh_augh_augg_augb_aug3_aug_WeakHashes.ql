/**
 * @name Weak cryptographic hash algorithms
 * @description Detects the utilization of cryptographic hash functions that have been
 *              deprecated or are deemed insecure for security-critical implementations.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required Python language support and cryptographic analysis libraries
import python
import experimental.cryptography.Concepts

// Locate hash function implementations utilizing weak or deprecated cryptographic algorithms
from HashAlgorithm hashImplementation, string algorithmIdentifier, string alertMessage
where
  // Retrieve the algorithm name from the hash function implementation
  algorithmIdentifier = hashImplementation.getHashName() and
  // Filter out implementations employing secure, approved hash algorithms
  not algorithmIdentifier = ["SHA256", "SHA384", "SHA512"] and
  // Construct appropriate security alert based on algorithm identification status
  (
    // Scenario: Algorithm is identified but not approved for security-sensitive use
    algorithmIdentifier != "" and
    alertMessage = "Detected usage of unapproved hash algorithm or API: " + algorithmIdentifier + "."
  )
  or
  (
    // Scenario: Algorithm cannot be identified or is unrecognized
    algorithmIdentifier = "" and
    alertMessage = "Detected usage of unrecognized hash algorithm."
  )
select hashImplementation, alertMessage