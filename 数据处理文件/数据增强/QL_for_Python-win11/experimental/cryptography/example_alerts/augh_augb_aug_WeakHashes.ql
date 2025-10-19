/**
 * @name Weak cryptographic hashes
 * @description Detects usage of cryptographic hash algorithms that are either unapproved or considered weak.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required Python libraries and experimental cryptography concepts
import python
import experimental.cryptography.Concepts

// Identify weak hash operations and generate corresponding warnings
from HashAlgorithm cryptoHash, string algorithmName, string alertMessage
where
  // Extract the algorithm name from the hash operation
  algorithmName = cryptoHash.getHashName() and
  // Exclude approved strong hash algorithms (SHA256, SHA384, SHA512)
  not algorithmName in ["SHA256", "SHA384", "SHA512"] and
  // Generate alert message based on algorithm recognition status
  (
    // Case: Recognized but unapproved algorithm
    algorithmName != "" and
    alertMessage = "Use of unapproved hash algorithm or API " + algorithmName + "."
  )
  or
  (
    // Case: Unrecognized algorithm
    algorithmName = "" and
    alertMessage = "Use of unrecognized hash algorithm."
  )
select cryptoHash, alertMessage