/**
 * @name Weak Cryptographic Hash Algorithms
 * @description Identifies the use of cryptographic hash algorithms that are either unapproved
 *              for security reasons or considered weak and vulnerable to attacks.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 *       security
 *       cryptography
 */

// Import Python language support and cryptographic concepts
import python
import experimental.cryptography.Concepts

// Identify weak hash algorithm operations, their algorithm names, and corresponding security warnings
from HashAlgorithm hashAlgoOperation, string algorithmName, string securityWarning
where
  // Extract the name of the hash algorithm being used
  algorithmName = hashAlgoOperation.getHashName() and
  // Filter out approved strong hash algorithms (SHA256, SHA384, SHA512)
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate security warning based on algorithm recognition status
  (
    algorithmName = unknownAlgorithm() and
    securityWarning = "Use of unrecognized hash algorithm."
    or
    not algorithmName = unknownAlgorithm() and
    securityWarning = "Use of unapproved hash algorithm or API " + algorithmName + "."
  )
select hashAlgoOperation, securityWarning