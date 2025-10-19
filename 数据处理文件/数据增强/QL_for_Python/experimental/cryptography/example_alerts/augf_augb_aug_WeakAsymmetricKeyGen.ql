/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * Detects cryptographic implementations generating asymmetric keys
 * with insufficient bit length vulnerable to brute-force attacks.
 * Keys under 2048 bits are considered weak for standard asymmetric algorithms.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Identify vulnerable asymmetric key generation configurations
from AsymmetricKeyGen keyGenOp, DataFlow::Node keySizeConfigNode, int keyBitLength, string algoName
where
  // Extract cryptographic key size from configuration source
  keyBitLength = keyGenOp.getKeySizeInBits(keySizeConfigNode)
  and
  // Retrieve algorithm identification details
  algoName = keyGenOp.getAlgorithm().getName()
  and
  // Validate against minimum security threshold
  keyBitLength < 2048
  and
  // Exclude elliptic curve algorithms (different security models)
  not isEllipticCurveAlgorithm(algoName, _)
// Report findings with contextual configuration details
select keyGenOp,
  "Weak asymmetric key size (" + keyBitLength.toString() + " bits) for algorithm " +
    algoName + " configured at $@", keySizeConfigNode, keySizeConfigNode.toString()