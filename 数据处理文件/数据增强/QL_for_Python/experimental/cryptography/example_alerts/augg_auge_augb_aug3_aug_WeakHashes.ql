/**
 * @name Weak cryptographic hash algorithms
 * @description Identifies the use of cryptographic hash functions that are either
 *              not approved or considered weak for security-critical applications.
 *              This query flags hash functions that are not in the list of approved
 *              strong algorithms (SHA256, SHA384, SHA512) or are unrecognized.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import necessary Python modules and cryptography-related concepts
import python
import experimental.cryptography.Concepts

// Identify hash operations that use weak or unapproved cryptographic algorithms
from HashAlgorithm hashOperation, string algorithmName, string alertMessage
where
  // Extract the algorithm name from the hash operation
  algorithmName = hashOperation.getHashName() and
  // Exclude strong, approved hash algorithms from detection
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate warning based on algorithm recognition status
  (
    // Case: Algorithm is recognized but not approved
    algorithmName != "" and
    alertMessage = "Use of unapproved hash algorithm or API " + algorithmName + "."
    or
    // Case: Algorithm is not recognized
    algorithmName = "" and
    alertMessage = "Use of unrecognized hash algorithm."
  )
select hashOperation, alertMessage