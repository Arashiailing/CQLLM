/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * Identifies asymmetric cryptographic key generation operations
 * using keys with insufficient length (below 2048 bits).
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric key generation operations with inadequate key sizes
from AsymmetricKeyGen keyGenerationOp, 
     DataFlow::Node keySizeNode, 
     int keySizeValue, 
     string algoName
where
  // Retrieve the cryptographic algorithm name
  algoName = keyGenerationOp.getAlgorithm().getName() and
  // Exclude elliptic curve algorithms (different security paradigms apply)
  not isEllipticCurveAlgorithm(algoName, _) and
  // Extract key size from configuration node
  keySizeValue = keyGenerationOp.getKeySizeInBits(keySizeNode) and
  // Verify key size meets minimum security requirement
  keySizeValue < 2048
// Generate alert with detailed context about weak key generation
select keyGenerationOp,
  "Insufficient asymmetric key length (" + keySizeValue.toString() + " bits) for " +
    algoName + " algorithm specified at $@", keySizeNode, keySizeNode.toString()