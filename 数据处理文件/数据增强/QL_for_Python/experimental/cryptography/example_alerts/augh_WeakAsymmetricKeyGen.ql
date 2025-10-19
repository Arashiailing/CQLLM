/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * This query identifies cryptographic operations that generate asymmetric keys
 * with insufficient key sizes (less than 2048 bits), which may be vulnerable
 * to brute-force attacks. Elliptic curve algorithms are excluded from this check
 * as they use different security parameters.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Define variables representing the key generation operation, its configuration source,
// the key size in bits, and the cryptographic algorithm name
from AsymmetricKeyGen keyGenerationOperation, 
     DataFlow::Node configurationSource, 
     int keySizeInBits, 
     string algorithmName
where
  // Extract the key size in bits from the configuration source of the key generation operation
  keySizeInBits = keyGenerationOperation.getKeySizeInBits(configurationSource) and
  // Verify that the key size is below the recommended minimum threshold of 2048 bits
  keySizeInBits < 2048 and
  // Retrieve the name of the cryptographic algorithm being used for key generation
  algorithmName = keyGenerationOperation.getAlgorithm().getName() and
  // Exclude elliptic curve algorithms from this analysis as they have different security considerations
  not isEllipticCurveAlgorithm(algorithmName, _)
select keyGenerationOperation,
  // Generate an alert message detailing the weak key size and algorithm used,
  // with a reference to the configuration source where the weak key size was specified
  "Use of weak asymmetric key size (" + keySizeInBits.toString() + " bits) for algorithm " +
    algorithmName + " at config source $@", configurationSource, configurationSource.toString()