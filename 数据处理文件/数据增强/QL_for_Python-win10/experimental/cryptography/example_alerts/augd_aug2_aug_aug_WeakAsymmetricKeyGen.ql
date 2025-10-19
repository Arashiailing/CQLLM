/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * Detects asymmetric cryptographic key generation operations using
 * insufficient key sizes (below 2048 bits), making them vulnerable
 * to brute-force attacks.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric key generation operations with inadequate key strength
from AsymmetricKeyGen asymmetricKeyGeneration, DataFlow::Node keyConfigNode, int keySizeBits, string algorithmName
where
  // Retrieve cryptographic configuration parameters
  (
    keySizeBits = asymmetricKeyGeneration.getKeySizeInBits(keyConfigNode) and
    algorithmName = asymmetricKeyGeneration.getAlgorithm().getName()
  ) and
  // Apply security validation criteria
  (
    keySizeBits < 2048 and
    not isEllipticCurveAlgorithm(algorithmName, _)
  )
// Report vulnerable configurations with contextual details
select asymmetricKeyGeneration,
  "Weak asymmetric key size (" + keySizeBits.toString() + " bits) for algorithm " +
    algorithmName + " configured at $@", keyConfigNode, keyConfigNode.toString()