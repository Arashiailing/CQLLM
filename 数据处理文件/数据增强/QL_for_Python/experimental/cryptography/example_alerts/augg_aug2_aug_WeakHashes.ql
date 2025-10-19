/**
 * @name Weak cryptographic hash algorithms
 * @description Identifies cryptographic hash functions that are either deprecated 
 *              or deemed insecure for security-critical applications.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required Python modules and experimental cryptography definitions
import python
import experimental.cryptography.Concepts

// Locate weak hash algorithm usages and generate corresponding security warnings
from HashAlgorithm hashOperation, string algorithmName, string alertMessage
where
  // Retrieve the hash algorithm identifier
  algorithmName = hashOperation.getHashName() and
  // Exclude strong, approved hash algorithms
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate alert message based on algorithm status
  (
    algorithmName != "" and
    alertMessage = "Use of unapproved hash algorithm or API " + algorithmName + "."
    // Case: Algorithm is identified but not approved
  )
  or
  (
    algorithmName = "" and
    alertMessage = "Use of unrecognized hash algorithm."
    // Case: Algorithm cannot be identified
  )
select hashOperation, alertMessage