/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * Identifies cryptographic operations that generate asymmetric keys
 * with insufficient bit length (below 2048 bits), which may compromise security.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Locate asymmetric key generation with insufficient security strength
from AsymmetricKeyGen asymmetricKeyGeneration, DataFlow::Node configurationSource, int keyBitLength, string algorithmIdentifier
where
  // Determine the bit length of the generated key from its configuration
  keyBitLength = asymmetricKeyGeneration.getKeySizeInBits(configurationSource) and
  // Check if the key size falls below the recommended security threshold
  keyBitLength < 2048 and
  // Obtain the name of the cryptographic algorithm being used
  algorithmIdentifier = asymmetricKeyGeneration.getAlgorithm().getName() and
  // Filter out elliptic curve algorithms as they follow different security paradigms
  not isEllipticCurveAlgorithm(algorithmIdentifier, _)
// Generate alert with details about the weak key configuration
select asymmetricKeyGeneration,
  "Weak asymmetric key size (" + keyBitLength.toString() + " bits) for algorithm " +
    algorithmIdentifier + " configured at $@", configurationSource, configurationSource.toString()