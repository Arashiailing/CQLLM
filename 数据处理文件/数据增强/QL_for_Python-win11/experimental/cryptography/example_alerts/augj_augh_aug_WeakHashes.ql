/**
 * @name Weak cryptographic hash algorithms
 * @description Identifies the use of cryptographic hash algorithms that are either unapproved or considered weak for security purposes.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import necessary Python language support and experimental cryptography analysis modules
import python
import experimental.cryptography.Concepts

// Detect weak or unapproved hash operations and generate corresponding security alerts
from HashAlgorithm hashOperation, string algorithmName, string securityWarning
where
  // Extract the algorithm name from the hash operation being analyzed
  algorithmName = hashOperation.getHashName() and
  // Filter out operations using approved strong hash algorithms (SHA256, SHA384, SHA512)
  not algorithmName in ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate security warning based on algorithm recognition status
  (
    // Handle recognized but unapproved algorithms
    algorithmName != "" and
    securityWarning = "Use of unapproved hash algorithm or API " + algorithmName + "."
  )
  or
  (
    // Handle unrecognized algorithms
    algorithmName = "" and
    securityWarning = "Use of unrecognized hash algorithm."
  )
select hashOperation, securityWarning