/**
 * @name Weak asymmetric key generation with insufficient key size (< 2048 bits)
 * @description
 * Detects asymmetric cryptographic key generation processes that utilize
 * inadequate key lengths (under 2048 bits), making them susceptible to brute-force attacks.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// This query identifies asymmetric key generation with insufficient key strength
from AsymmetricKeyGen asymmetricKeyOp, DataFlow::Node keyConfigNode, int keySizeBits, string encryptionAlgorithm
where
  // Retrieve key configuration parameters
  keySizeBits = asymmetricKeyOp.getKeySizeInBits(keyConfigNode) and
  encryptionAlgorithm = asymmetricKeyOp.getAlgorithm().getName() and
  (
    // Enforce security requirements: verify key size
    keySizeBits < 2048
    // Filter out elliptic curve algorithms
    and not isEllipticCurveAlgorithm(encryptionAlgorithm, _)
  )
// Output results with context about the vulnerable key configuration
select asymmetricKeyOp,
  "Weak asymmetric key size (" + keySizeBits.toString() + " bits) for algorithm " +
    encryptionAlgorithm + " configured at $@", keyConfigNode, keyConfigNode.toString()