/**
 * @name Weak asymmetric key generation with insufficient key size (< 2048 bits)
 * @description
 * Detects cryptographic operations that generate asymmetric keys with sizes below the recommended
 * security threshold of 2048 bits, which are susceptible to brute-force attacks.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// This query identifies asymmetric key generation operations with insufficient key strength
from AsymmetricKeyGen keyGenOperation, DataFlow::Node keyConfigurationNode, int keySizeBits, string algorithmName
where
  // Extract cryptographic key configuration details
  (
    keySizeBits = keyGenOperation.getKeySizeInBits(keyConfigurationNode) and
    algorithmName = keyGenOperation.getAlgorithm().getName()
  ) and
  // Apply security threshold filters
  (
    keySizeBits < 2048 and
    not isEllipticCurveAlgorithm(algorithmName, _)
  )
// Generate alert with details about the weak key configuration
select keyGenOperation,
  "Weak asymmetric key size (" + keySizeBits.toString() + " bits) for algorithm " +
    algorithmName + " configured at $@", keyConfigurationNode, keyConfigurationNode.toString()