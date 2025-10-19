/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * Detects use of weak asymmetric key sizes (less than 2048 bits).
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric key generation operations with insufficient key strength
from AsymmetricKeyGen keyGeneration, DataFlow::Node configurationSource, int keySizeBits, string algorithmIdentifier
where
  // Extract the key size from its configuration origin
  keySizeBits = keyGeneration.getKeySizeInBits(configurationSource) and
  // Verify the key size against minimum security threshold
  keySizeBits < 2048 and
  // Obtain the algorithm name for reporting
  algorithmIdentifier = keyGeneration.getAlgorithm().getName() and
  // Exclude elliptic curve algorithms (they follow different security models)
  not isEllipticCurveAlgorithm(algorithmIdentifier, _)
// Report findings with contextual information about the weak configuration
select keyGeneration,
  "Weak asymmetric key size (" + keySizeBits.toString() + " bits) for algorithm " +
    algorithmIdentifier + " configured at $@", configurationSource, configurationSource.toString()