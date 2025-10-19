/**
 * @name Weak cryptographic hash detection
 * @description Finds instances where cryptographic hash functions that are either deprecated or considered cryptographically weak are being used.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required Python modules and experimental cryptography functionality
import python
import experimental.cryptography.Concepts

// Identify weak hash algorithm usage with appropriate alert messages
from HashAlgorithm hashOperation, string algorithmName, string alertMessage
where
  // Extract the algorithm name from the hash operation
  algorithmName = hashOperation.getHashName() and
  // Filter out strong, approved hash algorithms
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Determine alert message based on algorithm recognition status
  (
    // Handle recognized but unapproved algorithms
    algorithmName != "" and
    alertMessage = "Detected use of unapproved hash algorithm or API: " + algorithmName + "."
  )
  or
  (
    // Handle unrecognized algorithms
    algorithmName = "" and
    alertMessage = "Detected use of unrecognized hash algorithm."
  )
select hashOperation, alertMessage