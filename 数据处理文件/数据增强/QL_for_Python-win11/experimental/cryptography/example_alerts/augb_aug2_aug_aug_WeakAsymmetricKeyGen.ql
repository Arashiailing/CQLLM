/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * Detects asymmetric cryptographic key generation operations using
 * insufficient key sizes (below 2048 bits), which are vulnerable to brute-force attacks.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric key generation operations with weak cryptographic parameters
from AsymmetricKeyGen keyGeneration, DataFlow::Node keyConfigNode, int keySizeBits, string algorithmName
where
  // Extract cryptographic configuration details
  keySizeBits = keyGeneration.getKeySizeInBits(keyConfigNode) and
  algorithmName = keyGeneration.getAlgorithm().getName() and
  // Apply security constraints: validate key strength and exclude elliptic curve algorithms
  keySizeBits < 2048 and
  not isEllipticCurveAlgorithm(algorithmName, _)
// Report findings with contextual information about the vulnerable configuration
select keyGeneration,
  "Weak asymmetric key size (" + keySizeBits.toString() + " bits) for algorithm " +
    algorithmName + " configured at $@", keyConfigNode, keyConfigNode.toString()