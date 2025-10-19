/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * Detects asymmetric cryptographic key generation processes
 * that utilize keys with insufficient length (below 2048 bits).
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Find asymmetric key generation operations with inadequate key sizes
from AsymmetricKeyGen keyGenOperation, 
     DataFlow::Node keySizeConfig, 
     int keySizeBits, 
     string cryptoAlgorithm
where
  // Obtain the cryptographic algorithm name
  cryptoAlgorithm = keyGenOperation.getAlgorithm().getName() and
  // Filter out elliptic curve algorithms (they follow different security paradigms)
  not isEllipticCurveAlgorithm(cryptoAlgorithm, _) and
  // Determine the key size from the configuration node
  keySizeBits = keyGenOperation.getKeySizeInBits(keySizeConfig) and
  // Check if the key size meets the minimum security requirement
  keySizeBits < 2048
// Generate alert with detailed context about the weak key generation
select keyGenOperation,
  "Insufficient asymmetric key length (" + keySizeBits.toString() + " bits) for " +
    cryptoAlgorithm + " algorithm specified at $@", keySizeConfig, keySizeConfig.toString()