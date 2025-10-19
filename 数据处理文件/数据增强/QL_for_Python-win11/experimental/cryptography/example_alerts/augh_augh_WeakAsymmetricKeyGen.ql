/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * Detects asymmetric cryptographic key generation operations that use
 * insufficient key strength (below 2048 bits), making them vulnerable
 * to cryptographic attacks.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric key generation operations with weak key sizes
from AsymmetricKeyGen keyGeneration, DataFlow::Node configurationSource, int keySizeInBits, string cryptoAlgorithm
where
  // Extract key size in bits from configuration source
  keySizeInBits = keyGeneration.getKeySizeInBits(configurationSource) and
  // Verify key size is below security threshold
  keySizeInBits < 2048 and
  // Retrieve cryptographic algorithm name
  cryptoAlgorithm = keyGeneration.getAlgorithm().getName() and
  // Exclude elliptic curve algorithms (different security metrics apply)
  not isEllipticCurveAlgorithm(cryptoAlgorithm, _)
select keyGeneration,
  // Report weak key configuration with size, algorithm, and source location
  "Use of weak asymmetric key size (" + keySizeInBits.toString() + " bits) for algorithm " +
    cryptoAlgorithm + " at config source $@", configurationSource, configurationSource.toString()