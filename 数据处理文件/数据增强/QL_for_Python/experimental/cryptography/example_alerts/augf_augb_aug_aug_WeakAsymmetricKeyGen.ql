/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * Detects use of weak asymmetric key sizes (less than 2048 bits).
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Locate asymmetric key generation operations with insufficient key strength
from AsymmetricKeyGen cryptoKeyGen, DataFlow::Node keyConfigNode, int keySizeBits, string algorithmName
where
  // Extract key size from configuration source
  keySizeBits = cryptoKeyGen.getKeySizeInBits(keyConfigNode) and
  // Verify key size is below minimum security requirement
  keySizeBits < 2048 and
  // Obtain algorithm name for reporting
  algorithmName = cryptoKeyGen.getAlgorithm().getName() and
  // Exclude elliptic curve algorithms (different security paradigms)
  not isEllipticCurveAlgorithm(algorithmName, _)
// Report findings with context about the weak key configuration
select cryptoKeyGen,
  "Weak asymmetric key size (" + keySizeBits.toString() + " bits) for algorithm " +
    algorithmName + " configured at $@", keyConfigNode, keyConfigNode.toString()