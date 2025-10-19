/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * Identifies cryptographic implementations that generate asymmetric keys
 * with insufficient bit length, which may be vulnerable to brute-force attacks.
 * Keys smaller than 2048 bits are considered weak for most asymmetric algorithms.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric key generation operations with weak key sizes
from AsymmetricKeyGen keyGeneration, DataFlow::Node keySizeSource, int keySizeBits, string algorithmName
where
  // Extract key size from configuration source
  keySizeBits = keyGeneration.getKeySizeInBits(keySizeSource) and
  // Retrieve algorithm identification
  algorithmName = keyGeneration.getAlgorithm().getName() and
  // Validate key strength against security threshold
  keySizeBits < 2048 and
  // Exclude elliptic curve algorithms (use different security models)
  not isEllipticCurveAlgorithm(algorithmName, _)
// Report findings with contextual information
select keyGeneration,
  "Weak asymmetric key size (" + keySizeBits.toString() + " bits) for algorithm " +
    algorithmName + " configured at $@", keySizeSource, keySizeSource.toString()