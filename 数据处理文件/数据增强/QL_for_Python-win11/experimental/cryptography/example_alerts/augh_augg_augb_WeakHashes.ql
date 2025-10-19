/**
 * @name Weak hashes
 * @description Detects cryptographic hash algorithms that are either unrecognized or considered weak for security purposes.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import Python language support and cryptographic concepts
import python
import experimental.cryptography.Concepts

// Query for weak hash operations, their algorithm names, and corresponding security warnings
from HashAlgorithm hashOperation, string algorithmName, string warningMessage
where
  // Extract the algorithm name from the hash operation
  algorithmName = hashOperation.getHashName() and
  // Exclude strong, approved hash algorithms from the results
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Determine appropriate security warning message based on algorithm status
  (
    // Handle case of unrecognized algorithm
    algorithmName = unknownAlgorithm() and
    warningMessage = "Use of unrecognized hash algorithm."
    or
    // Handle case of recognized but unapproved algorithm
    not algorithmName = unknownAlgorithm() and
    warningMessage = "Use of unapproved hash algorithm or API " + algorithmName + "."
  )
select hashOperation, warningMessage