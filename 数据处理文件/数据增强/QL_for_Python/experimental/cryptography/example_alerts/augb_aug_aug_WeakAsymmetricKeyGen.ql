/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * Detects use of weak asymmetric key sizes (less than 2048 bits).
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric key generation operations that use insufficient key strength
from AsymmetricKeyGen keyGenOp, DataFlow::Node configNode, int keyBitLength, string algoName
where
  // Retrieve the key size parameter from its configuration source
  keyBitLength = keyGenOp.getKeySizeInBits(configNode) and
  // Validate key size against minimum security requirement
  keyBitLength < 2048 and
  // Extract algorithm name for detailed reporting
  algoName = keyGenOp.getAlgorithm().getName() and
  // Filter out elliptic curve algorithms (they use different security paradigms)
  not isEllipticCurveAlgorithm(algoName, _)
// Generate alert with contextual information about the weak key configuration
select keyGenOp,
  "Weak asymmetric key size (" + keyBitLength.toString() + " bits) for algorithm " +
    algoName + " configured at $@", configNode, configNode.toString()