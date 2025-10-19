/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * Identifies asymmetric cryptographic key generation operations that use
 * insufficient key sizes (below 2048 bits), which are vulnerable to brute-force attacks.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Query for asymmetric key generation operations with insufficient key strength
from AsymmetricKeyGen keyGenOperation, DataFlow::Node configNode, int keyBitLength, string cryptoAlgorithm
where
  // Extract key configuration details
  keyBitLength = keyGenOperation.getKeySizeInBits(configNode) and
  cryptoAlgorithm = keyGenOperation.getAlgorithm().getName() and
  // Apply security constraints: check key size and exclude elliptic curve algorithms
  keyBitLength < 2048 and
  not isEllipticCurveAlgorithm(cryptoAlgorithm, _)
// Report findings with contextual information about the weak configuration
select keyGenOperation,
  "Weak asymmetric key size (" + keyBitLength.toString() + " bits) for algorithm " +
    cryptoAlgorithm + " configured at $@", configNode, configNode.toString()