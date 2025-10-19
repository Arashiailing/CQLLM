/**
 * @name Weak cryptographic hash algorithms
 * @description Identifies usage of deprecated/insecure cryptographic hash functions
 *              that violate security best practices
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from HashAlgorithm cryptoHashOperation, string hashAlgorithmName, string alertMessage
where
  // Extract algorithm name from cryptographic operation
  hashAlgorithmName = cryptoHashOperation.getHashName()
  // Exclude strong SHA-2 family algorithms
  and not hashAlgorithmName = ["SHA256", "SHA384", "SHA512"]
  // Generate appropriate warning based on algorithm recognition status
  and (
    // Case: Recognized but insecure algorithm
    (hashAlgorithmName != "" and alertMessage = "Detected unapproved hash algorithm: " + hashAlgorithmName)
    or
    // Case: Unrecognized algorithm (potential security risk)
    (hashAlgorithmName = "" and alertMessage = "Unrecognized cryptographic hash algorithm detected")
  )
select cryptoHashOperation, alertMessage