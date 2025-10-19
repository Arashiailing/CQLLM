/**
 * @name Weak cryptographic hash algorithms
 * @description Identifies the use of cryptographic hash functions that are either
 *              not approved or considered weak for security-critical applications.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required Python modules and cryptographic concepts
import python
import experimental.cryptography.Concepts

// Identify hash operations utilizing weak or unapproved cryptographic algorithms
from HashAlgorithm hashOperation, string algorithmName, string alertMessage
where
  // Extract the algorithm name from the hash operation
  algorithmName = hashOperation.getHashName() and
  // Filter out strong, approved hash algorithms
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Determine appropriate alert message based on algorithm recognition
  (
    // Handle recognized but unapproved algorithms
    algorithmName != "" and
    alertMessage = "Use of unapproved hash algorithm or API " + algorithmName + "."
    or
    // Handle unrecognized algorithms
    algorithmName = "" and
    alertMessage = "Use of unrecognized hash algorithm."
  )
select hashOperation, alertMessage