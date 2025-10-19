/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * Identifies asymmetric cryptographic key generation operations
 * using insecure key sizes below 2048 bits, vulnerable to brute-force attacks.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Locate asymmetric key generation operations with weak cryptographic parameters
from AsymmetricKeyGen keyGenOp, DataFlow::Node configNode, int keyBitSize, string algoName
where
  // Retrieve cryptographic configuration details
  keyBitSize = keyGenOp.getKeySizeInBits(configNode) and
  algoName = keyGenOp.getAlgorithm().getName() and
  // Apply security constraints: check key strength and exclude elliptic curve algorithms
  keyBitSize < 2048 and
  not isEllipticCurveAlgorithm(algoName, _)
// Report findings with contextual vulnerability information
select keyGenOp,
  "Weak asymmetric key size (" + keyBitSize.toString() + " bits) for algorithm " +
    algoName + " configured at $@", configNode, configNode.toString()