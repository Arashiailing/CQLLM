/**
 * @name Weak asymmetric key generation (key size < 2048 bits)
 * @description
 * Detects asymmetric cryptographic key generation operations
 * that use insufficiently sized keys (under 2048 bits).
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Identify vulnerable asymmetric key generation operations
from AsymmetricKeyGen keyGenOp, 
     DataFlow::Node configSource, 
     int keySizeBits, 
     string algoName
where
  // Obtain algorithm identifier and exclude elliptic curve cryptography
  algoName = keyGenOp.getAlgorithm().getName() and
  not isEllipticCurveAlgorithm(algoName, _) and
  
  // Extract key size from configuration source
  keySizeBits = keyGenOp.getKeySizeInBits(configSource) and
  
  // Validate key strength against security threshold
  keySizeBits < 2048
// Report findings with contextual details
select keyGenOp,
  "Weak asymmetric key size (" + keySizeBits.toString() + " bits) for algorithm " +
    algoName + " configured at $@", configSource, configSource.toString()