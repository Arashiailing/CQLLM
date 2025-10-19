/**
 * @name Weak asymmetric key generation with insufficient key size (< 2048 bits)
 * @description
 * Identifies cryptographic operations that generate asymmetric keys with sizes below the recommended
 * security threshold of 2048 bits, which may be vulnerable to brute-force attacks.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// This query detects asymmetric key generation operations with insufficient cryptographic strength
from AsymmetricKeyGen keyGenerationOp, DataFlow::Node keyConfigurationNode, int keySizeBits, string algorithmName
where
  // Extract key configuration information from the cryptographic operation
  keySizeBits = keyGenerationOp.getKeySizeInBits(keyConfigurationNode) and
  algorithmName = keyGenerationOp.getAlgorithm().getName() and
  
  // Apply security criteria to identify vulnerable key configurations
  keySizeBits < 2048 and
  not isEllipticCurveAlgorithm(algorithmName, _)
  
// Generate security alert with details about the weak key configuration
select keyGenerationOp,
  "Weak asymmetric key size (" + keySizeBits.toString() + " bits) for algorithm " +
    algorithmName + " configured at $@", keyConfigurationNode, keyConfigurationNode.toString()