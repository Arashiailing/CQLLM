/**
 * @name Insufficient asymmetric key length (< 2048 bits)
 * @description
 * Identifies cryptographic implementations that create asymmetric keys
 * with inadequate bit length, making them susceptible to brute-force attacks.
 * Keys below 2048 bits are deemed insecure for conventional asymmetric algorithms.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Identify cryptographic operations with inadequate key length
from AsymmetricKeyGen vulnerableKeyGen, DataFlow::Node sizeConfigNode, int keyBitLen, string algorithmName
where
  // Extract key size configuration from the cryptographic operation
  keyBitLen = vulnerableKeyGen.getKeySizeInBits(sizeConfigNode)
  and
  // Retrieve algorithm identification
  algorithmName = vulnerableKeyGen.getAlgorithm().getName()
  and
  // Apply security threshold check
  keyBitLen < 2048
  and
  // Exclude elliptic curve cryptography (different security model)
  not isEllipticCurveAlgorithm(algorithmName, _)
// Report security findings with configuration details
select vulnerableKeyGen,
  "Insecure asymmetric key size (" + keyBitLen.toString() + " bits) for algorithm " +
    algorithmName + " configured at $@", sizeConfigNode, sizeConfigNode.toString()