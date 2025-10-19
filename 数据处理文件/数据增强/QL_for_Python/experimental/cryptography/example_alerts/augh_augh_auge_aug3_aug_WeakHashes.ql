/**
 * @name Weak cryptographic hash algorithms
 * @description Identifies cryptographic hash functions that are deprecated 
 *              or considered insecure for security-sensitive contexts.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import Python language support and cryptographic analysis utilities
import python
import experimental.cryptography.Concepts

// Find hash operations utilizing weak or deprecated cryptographic algorithms
from HashAlgorithm hashOperation, string algorithmName, string alertMessage
where
  // Extract the algorithm name from the cryptographic hash operation
  algorithmName = hashOperation.getHashName() and
  
  // Filter out approved strong hash algorithms
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  
  // Generate appropriate alert message based on algorithm status
  (
    // Case for recognized but unapproved algorithms
    algorithmName != "" and
    alertMessage = "Use of unapproved hash algorithm or API " + algorithmName + "."
  )
  or
  (
    // Case for unrecognized algorithm cases
    algorithmName = "" and
    alertMessage = "Use of unrecognized hash algorithm."
  )
select hashOperation, alertMessage