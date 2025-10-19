/**
 * @name Weak cryptographic hash algorithms
 * @description Identifies usage of cryptographic hash algorithms that are either unapproved 
 *              for security purposes or considered cryptographically weak.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import Python language support and cryptographic concepts
import python
import experimental.cryptography.Concepts

// Identify weak cryptographic hash operations and generate appropriate security alerts
from HashAlgorithm cryptoHashOperation, string algorithmName, string securityAlert
where
  // Extract the cryptographic hash algorithm name from the operation
  algorithmName = cryptoHashOperation.getHashName() and
  // Exclude approved strong cryptographic hash algorithms
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate security alert based on algorithm recognition status
  (
    algorithmName = unknownAlgorithm() and
    securityAlert = "Use of unrecognized cryptographic hash algorithm."
    or
    not algorithmName = unknownAlgorithm() and
    securityAlert = "Use of unapproved cryptographic hash algorithm or API: " + algorithmName + "."
  )
select cryptoHashOperation, securityAlert