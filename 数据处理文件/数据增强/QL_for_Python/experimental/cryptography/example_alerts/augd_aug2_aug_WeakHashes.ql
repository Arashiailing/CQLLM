/**
 * @name Weak cryptographic hash algorithms
 * @description Identifies usage of cryptographic hash functions that are either 
 *              not approved or deemed weak for security applications.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required Python modules and experimental cryptography components
import python
import experimental.cryptography.Concepts

// Detect weak hash operations and generate corresponding security warnings
from HashAlgorithm hashOperation, string algorithmName, string alertMessage
where
  // Retrieve the name of the hash algorithm in use
  algorithmName = hashOperation.getHashName() and
  // Exclude strong, approved cryptographic hash algorithms
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate security alert based on algorithm recognition status
  (
    // Case for recognized but unapproved algorithms
    algorithmName != "" and
    alertMessage = "Use of unapproved hash algorithm or API " + algorithmName + "."
  )
  or
  (
    // Case for unrecognized algorithms
    algorithmName = "" and
    alertMessage = "Use of unrecognized hash algorithm."
  )
select hashOperation, alertMessage