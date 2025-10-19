/**
 * @name Weak asymmetric key generation with insufficient key size (< 2048 bits)
 * @description
 * Identifies asymmetric cryptographic key generation operations that use key sizes below
 * the 2048-bit security threshold, making them vulnerable to brute-force attacks.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric key generation operations with insufficient key strength
from AsymmetricKeyGen keyGeneration, DataFlow::Node configNode, int keySize, string algoName
where
  // Extract cryptographic key configuration details
  (
    keySize = keyGeneration.getKeySizeInBits(configNode) and
    algoName = keyGeneration.getAlgorithm().getName()
  )
  // Apply security threshold filters
  and (
    keySize < 2048 and
    not isEllipticCurveAlgorithm(algoName, _)
  )
// Generate alert with details about the weak key configuration
select keyGeneration,
  "Weak asymmetric key size (" + keySize.toString() + " bits) for algorithm " +
    algoName + " configured at $@", configNode, configNode.toString()