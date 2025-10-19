/**
 * @name Insufficient key length in asymmetric cryptography (< 2048 bits)
 * @description
 * Identifies asymmetric cryptographic key generation processes
 * that create keys with insufficient bit length (below 2048 bits),
 * which may introduce security vulnerabilities.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric key generation operations with insufficient key size
from AsymmetricKeyGen keyGeneration, DataFlow::Node configurationNode, string cryptographicAlgorithm, int keyBitLength
where
  // Extract cryptographic algorithm information
  cryptographicAlgorithm = keyGeneration.getAlgorithm().getName() and
  // Calculate key bit length from configuration
  keyBitLength = keyGeneration.getKeySizeInBits(configurationNode) and
  (
    // Check for insufficient key size
    keyBitLength < 2048
    // Exclude elliptic curve algorithms (different security model)
    and not isEllipticCurveAlgorithm(cryptographicAlgorithm, _)
  )
// Report findings with security context and configuration details
select keyGeneration,
  "Insecure asymmetric key size (" + keyBitLength.toString() + " bits) for " +
    cryptographicAlgorithm + " algorithm configured at $@", configurationNode, configurationNode.toString()