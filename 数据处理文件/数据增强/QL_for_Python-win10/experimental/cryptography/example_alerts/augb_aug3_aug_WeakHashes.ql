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

// Import required Python modules and cryptography-related concepts
import python
import experimental.cryptography.Concepts

// Identify hash operations that utilize weak or unapproved cryptographic algorithms
from HashAlgorithm hashOperation, string algoName, string alertMessage
where
  // Extract the algorithm name from the hash operation
  algoName = hashOperation.getHashName() and
  // Exclude strong, approved hash algorithms from detection
  not algoName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate alert based on algorithm recognition status
  (
    // Case: Algorithm is recognized but not approved
    algoName != "" and
    alertMessage = "Use of unapproved hash algorithm or API " + algoName + "."
  )
  or
  (
    // Case: Algorithm is not recognized
    algoName = "" and
    alertMessage = "Use of unrecognized hash algorithm."
  )
select hashOperation, alertMessage