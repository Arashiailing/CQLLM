/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * Detects asymmetric cryptographic key generation operations using
 * insufficient key sizes (below 2048 bits), making them vulnerable to
 * brute-force attacks. Excludes elliptic curve algorithms which use
 * different security parameters.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Identify weak asymmetric key generation operations
from AsymmetricKeyGen weakKeyGen, DataFlow::Node keyConfigNode, int keySizeBits, string algorithmName
where
  // Extract cryptographic configuration details
  keySizeBits = weakKeyGen.getKeySizeInBits(keyConfigNode) and
  algorithmName = weakKeyGen.getAlgorithm().getName() and
  // Apply security constraints: verify key size and exclude elliptic curve algorithms
  keySizeBits < 2048 and
  not isEllipticCurveAlgorithm(algorithmName, _)
// Report findings with contextual configuration information
select weakKeyGen,
  "Weak asymmetric key size (" + keySizeBits.toString() + " bits) for algorithm " +
    algorithmName + " configured at $@", keyConfigNode, keyConfigNode.toString()