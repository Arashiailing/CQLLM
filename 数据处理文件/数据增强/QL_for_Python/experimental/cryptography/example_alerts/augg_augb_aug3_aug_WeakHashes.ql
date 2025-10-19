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

// Import necessary Python modules and cryptographic analysis components
import python
import experimental.cryptography.Concepts

// Find hash function implementations using weak or deprecated cryptographic algorithms
from HashAlgorithm hashFunc, string algorithmName, string warningMsg
where
  // Extract the algorithm identifier from the hash function
  algorithmName = hashFunc.getHashName() and
  // Filter out strong, approved hash algorithms
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Determine appropriate warning message based on algorithm recognition status
  (
    // Scenario: Algorithm is identified but not approved for security use
    algorithmName != "" and
    warningMsg = "Detected usage of unapproved hash algorithm or API: " + algorithmName + "."
  )
  or
  (
    // Scenario: Algorithm cannot be identified or recognized
    algorithmName = "" and
    warningMsg = "Detected usage of unrecognized hash algorithm."
  )
select hashFunc, warningMsg