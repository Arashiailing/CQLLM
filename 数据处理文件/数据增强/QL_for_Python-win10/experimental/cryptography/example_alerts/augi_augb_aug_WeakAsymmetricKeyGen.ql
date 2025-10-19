/**
 * @name Weak asymmetric key generation (key size < 2048 bits)
 * @description
 * Detects cryptographic implementations generating asymmetric keys
 * with insufficient bit length vulnerable to brute-force attacks.
 * Keys below 2048 bits are considered weak for most asymmetric algorithms.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Identify weak asymmetric key generation operations
from AsymmetricKeyGen keyGenOp, DataFlow::Node sizeConfigNode, int keyBitLength, string algoName
where
  // Extract configured key size in bits
  keyBitLength = keyGenOp.getKeySizeInBits(sizeConfigNode) and
  // Retrieve cryptographic algorithm identifier
  algoName = keyGenOp.getAlgorithm().getName() and
  // Verify key meets minimum security threshold
  keyBitLength < 2048 and
  // Exclude elliptic curve algorithms (different security model)
  not isEllipticCurveAlgorithm(algoName, _)
// Report findings with configuration context
select keyGenOp,
  "Weak asymmetric key size (" + keyBitLength.toString() + " bits) for algorithm " +
    algoName + " configured at $@", sizeConfigNode, sizeConfigNode.toString()