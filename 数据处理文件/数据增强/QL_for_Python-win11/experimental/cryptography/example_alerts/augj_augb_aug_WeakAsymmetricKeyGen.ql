/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * Identifies cryptographic implementations that generate asymmetric keys
 * with insufficient bit length, which may be vulnerable to brute-force attacks.
 * Keys smaller than 2048 bits are considered weak for most asymmetric algorithms.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Detect asymmetric cryptographic key generation with insufficient bit strength
from AsymmetricKeyGen asymKeyGen, DataFlow::Node keySizeConfig, int bitLength, string cryptoAlgorithm
where
  // Obtain key size information from the configuration source
  bitLength = asymKeyGen.getKeySizeInBits(keySizeConfig) and
  // Extract the cryptographic algorithm name for identification
  cryptoAlgorithm = asymKeyGen.getAlgorithm().getName() and
  // Apply security threshold check for key strength
  bitLength < 2048 and
  // Filter out elliptic curve algorithms (different security model applies)
  not isEllipticCurveAlgorithm(cryptoAlgorithm, _)
// Generate alert with details about the weak key configuration
select asymKeyGen,
  "Weak asymmetric key size (" + bitLength.toString() + " bits) for algorithm " +
    cryptoAlgorithm + " configured at $@", keySizeConfig, keySizeConfig.toString()