/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * Identifies asymmetric cryptographic key generation operations
 * using insufficient key sizes (below 2048 bits), which are
 * vulnerable to brute-force attacks.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Locate asymmetric key generation operations with insufficient key strength
from AsymmetricKeyGen keyGen, DataFlow::Node configNode, int keySize, string algoName
where
  // Extract cryptographic configuration details
  (
    keySize = keyGen.getKeySizeInBits(configNode) and
    algoName = keyGen.getAlgorithm().getName()
  ) and
  // Apply security validation criteria
  (
    keySize < 2048 and
    not isEllipticCurveAlgorithm(algoName, _)
  )
// Report vulnerable configurations with contextual information
select keyGen,
  "Weak asymmetric key size (" + keySize.toString() + " bits) for algorithm " +
    algoName + " configured at $@", configNode, configNode.toString()