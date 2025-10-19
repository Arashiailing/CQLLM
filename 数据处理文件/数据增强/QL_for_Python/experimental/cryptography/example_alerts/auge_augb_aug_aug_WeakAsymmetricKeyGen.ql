/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * Identifies instances where asymmetric cryptographic keys are generated with
 * insufficient bit length, potentially compromising security.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Query for asymmetric key generation operations with inadequate security parameters
from AsymmetricKeyGen asymKeyGeneration, DataFlow::Node keyConfigSource, int securityStrength, string cryptographicAlgorithm
where
  // Obtain the key size in bits from the configuration node
  securityStrength = asymKeyGeneration.getKeySizeInBits(keyConfigSource) and
  // Check if the key size meets minimum security standards
  securityStrength < 2048 and
  // Retrieve the algorithm name for reporting purposes
  cryptographicAlgorithm = asymKeyGeneration.getAlgorithm().getName() and
  // Exclude elliptic curve algorithms as they follow different security models
  not isEllipticCurveAlgorithm(cryptographicAlgorithm, _)
// Report findings with contextual details about the weak key configuration
select asymKeyGeneration,
  "Weak asymmetric key size (" + securityStrength.toString() + " bits) for algorithm " +
    cryptographicAlgorithm + " configured at $@", keyConfigSource, keyConfigSource.toString()