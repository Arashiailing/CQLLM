/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * Identifies asymmetric cryptographic key generation operations using
 * insufficient key strength (below 2048 bits), which are vulnerable
 * to cryptographic attacks.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Find asymmetric key generation operations with insufficient key strength
from AsymmetricKeyGen keyGenOp, DataFlow::Node configNode, int keyBitSize, string algoName
where
  // Extract key size from configuration source
  keyBitSize = keyGenOp.getKeySizeInBits(configNode) and
  // Verify key size meets minimum security threshold
  keyBitSize < 2048 and
  // Retrieve cryptographic algorithm identifier
  algoName = keyGenOp.getAlgorithm().getName() and
  // Exclude elliptic curve algorithms (different security metrics apply)
  not isEllipticCurveAlgorithm(algoName, _)
select keyGenOp,
  // Report weak key configuration with size, algorithm, and source location
  "Use of weak asymmetric key size (" + keyBitSize.toString() + " bits) for algorithm " +
    algoName + " at config source $@", configNode, configNode.toString()