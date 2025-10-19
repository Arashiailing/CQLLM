/**
 * @name Weak cryptographic hash algorithms
 * @description Detects the utilization of cryptographic hash functions that are
 *              either deprecated or considered insecure for security-sensitive contexts.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required Python modules and cryptographic analysis utilities
import python
import experimental.cryptography.Concepts

// Locate hash algorithm implementations employing weak or deprecated cryptographic methods
from HashAlgorithm hashImpl, string algoName, string warningMsg
where
  // Retrieve the algorithm identifier from the hash implementation
  algoName = hashImpl.getHashName() and
  // Filter out implementations using secure, approved hash algorithms (SHA256, SHA384, SHA512)
  not algoName = ["SHA256", "SHA384", "SHA512"] and
  // Construct security warning based on algorithm recognition status
  (
    // Scenario: Algorithm is identified but not approved for security-sensitive applications
    algoName != "" and
    warningMsg = "Detected usage of unapproved hash algorithm or API: " + algoName + "."
  )
  or
  (
    // Scenario: Algorithm cannot be identified or recognized
    algoName = "" and
    warningMsg = "Detected usage of unrecognized hash algorithm."
  )
select hashImpl, warningMsg