/**
 * @name Weak asymmetric key generation with insufficient key size (< 2048 bits)
 * @description
 * Identifies cryptographic operations that generate asymmetric keys with sizes below the recommended
 * security threshold of 2048 bits, which may be vulnerable to brute-force attacks.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Query to detect asymmetric key generation operations that use insufficient key strength
from AsymmetricKeyGen asymmetricKeyOp, DataFlow::Node keyConfigNode, int keyLengthBits, string cryptoAlgorithm
where
  // Extract key configuration details
  keyLengthBits = asymmetricKeyOp.getKeySizeInBits(keyConfigNode) and
  cryptoAlgorithm = asymmetricKeyOp.getAlgorithm().getName() and
  // Apply security filters
  keyLengthBits < 2048 and
  not isEllipticCurveAlgorithm(cryptoAlgorithm, _)
// Generate alert with details about the weak key configuration
select asymmetricKeyOp,
  "Weak asymmetric key size (" + keyLengthBits.toString() + " bits) for algorithm " +
    cryptoAlgorithm + " configured at $@", keyConfigNode, keyConfigNode.toString()