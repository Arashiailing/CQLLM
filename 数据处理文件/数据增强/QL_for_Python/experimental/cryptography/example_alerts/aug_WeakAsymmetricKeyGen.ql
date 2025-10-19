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

// Identify asymmetric key generation operations with weak key sizes
from AsymmetricKeyGen keyGenOp, DataFlow::Node configOrigin, int bitLength, string algoName
where
  // Extract key size from configuration source
  bitLength = keyGenOp.getKeySizeInBits(configOrigin) and
  // Validate key strength against security threshold
  bitLength < 2048 and
  // Retrieve algorithm identification
  algoName = keyGenOp.getAlgorithm().getName() and
  // Exclude elliptic curve algorithms (use different security models)
  not isEllipticCurveAlgorithm(algoName, _)
// Report findings with contextual information
select keyGenOp,
  "Weak asymmetric key size (" + bitLength.toString() + " bits) for algorithm " +
    algoName + " configured at $@", configOrigin, configOrigin.toString()