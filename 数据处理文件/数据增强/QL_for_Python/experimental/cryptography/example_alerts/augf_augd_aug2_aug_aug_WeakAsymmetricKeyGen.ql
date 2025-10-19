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

// Define query components with improved variable naming
from AsymmetricKeyGen keyGenOperation, DataFlow::Node configNode, int keySize, string algorithmName
where
  // Extract cryptographic configuration details
  (
    keySize = keyGenOperation.getKeySizeInBits(configNode) and
    algorithmName = keyGenOperation.getAlgorithm().getName()
  ) and
  // Apply security validation criteria
  (
    keySize < 2048 and
    not isEllipticCurveAlgorithm(algorithmName, _)
  )
// Report findings with contextual information
select keyGenOperation,
  "Weak asymmetric key size (" + keySize.toString() + " bits) for algorithm " +
    algorithmName + " configured at $@", configNode, configNode.toString()