/**
 * @name Weak asymmetric key generation with insufficient key size (< 2048 bits)
 * @description
 * Identifies asymmetric cryptographic key generation operations
 * that use key sizes below the 2048-bit security threshold.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Locate asymmetric key generation operations with inadequate key strength
from AsymmetricKeyGen keyGenOp, DataFlow::Node configSource, int keyLength, string algoName
where
  // Extract key size from configuration source
  keyLength = keyGenOp.getKeySizeInBits(configSource) and
  // Validate against minimum security requirement
  keyLength < 2048 and
  // Retrieve algorithm identifier for reporting
  algoName = keyGenOp.getAlgorithm().getName() and
  // Exclude elliptic curve algorithms (different security model)
  not isEllipticCurveAlgorithm(algoName, _)
// Report findings with configuration context
select keyGenOp,
  "Weak asymmetric key size (" + keyLength.toString() + " bits) for algorithm " +
    algoName + " configured at $@", configSource, configSource.toString()