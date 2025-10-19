/**
 * @name Weak cryptographic hash algorithms
 * @description Identifies cryptographic hash functions considered weak or unapproved 
 *              for security purposes, excluding only SHA-256, SHA-384, and SHA-512.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from HashAlgorithm hashOperation, string algorithmName, string alertMessage
where
  // Extract algorithm name from the hash operation
  algorithmName = hashOperation.getHashName() and
  // Exclude strong, approved hash algorithms
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate alert based on algorithm recognition status
  (
    // Case: Recognized but unapproved algorithm
    algorithmName != "" and
    alertMessage = "Use of unapproved hash algorithm or API " + algorithmName + "."
    or
    // Case: Unrecognized algorithm
    algorithmName = "" and
    alertMessage = "Use of unrecognized hash algorithm."
  )
select hashOperation, alertMessage