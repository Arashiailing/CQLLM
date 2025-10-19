/**
 * @name Insufficient key strength in asymmetric key generation (< 2048 bits)
 * @description
 * Identifies cryptographic operations that generate asymmetric keys with inadequate key sizes,
 * which are vulnerable to brute-force attacks.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Locate asymmetric key generation instances with substandard key lengths
from AsymmetricKeyGen keyGeneration, DataFlow::Node configurationSource, int keySizeBits, string algorithmName
where
  // Determine the key size in bits from the configuration source
  keySizeBits = keyGeneration.getKeySizeInBits(configurationSource) and
  // Retrieve the algorithm name for reporting purposes
  algorithmName = keyGeneration.getAlgorithm().getName() and
  // Verify the key size meets minimum security requirements
  keySizeBits < 2048 and
  // Filter out elliptic curve algorithms as they follow different security paradigms
  not isEllipticCurveAlgorithm(algorithmName, _)
// Generate alert with detailed vulnerability information
select keyGeneration,
  "Cryptographically weak asymmetric key size (" + keySizeBits.toString() + " bits) detected for " +
    algorithmName + " algorithm. Configuration specified at $@", configurationSource, configurationSource.toString()