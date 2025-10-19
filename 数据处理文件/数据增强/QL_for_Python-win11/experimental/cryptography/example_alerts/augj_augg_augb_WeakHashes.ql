/**
 * @name Weak hashes
 * @description Detects cryptographic hash functions that are either unrecognized or considered weak for security purposes.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import Python language support and cryptographic concepts
import python
import experimental.cryptography.Concepts

// Find hash operations with non-approved algorithms
from HashAlgorithm hashOperation, string algorithmName, string warningMessage
where
  // Extract the algorithm name from the hash operation
  algorithmName = hashOperation.getHashName() and
  // Exclude approved strong hash algorithms
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Generate context-specific security warnings
  (
    algorithmName = unknownAlgorithm() and
    warningMessage = "Use of unrecognized hash algorithm."
    or
    not algorithmName = unknownAlgorithm() and
    warningMessage = "Use of unapproved hash algorithm or API " + algorithmName + "."
  )
select hashOperation, warningMessage