/**
 * @name Insufficient key length in asymmetric key generation (< 2048 bits)
 * @description
 * Detects asymmetric cryptographic key generation operations that use
 * a bit length below the recommended minimum, which could lead to security vulnerabilities.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric key generation with suboptimal security parameters
from AsymmetricKeyGen cryptoKeyGeneration, DataFlow::Node keyParamSource, int bitSize, string algoName
where
  // Extract the key bit length from the configuration parameter
  bitSize = cryptoKeyGeneration.getKeySizeInBits(keyParamSource) and
  // Verify the key length against minimum security requirements
  bitSize < 2048 and
  // Obtain the cryptographic algorithm name for result reporting
  algoName = cryptoKeyGeneration.getAlgorithm().getName() and
  // Filter out elliptic curve algorithms due to their distinct security characteristics
  not isEllipticCurveAlgorithm(algoName, _)
// Generate alert with details about the inadequate key configuration
select cryptoKeyGeneration,
  "Weak asymmetric key size (" + bitSize.toString() + " bits) for algorithm " +
    algoName + " configured at $@", keyParamSource, keyParamSource.toString()