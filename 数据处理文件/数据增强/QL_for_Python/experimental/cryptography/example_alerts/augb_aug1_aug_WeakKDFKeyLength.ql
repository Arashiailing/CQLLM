/**
 * @name Insufficient KDF Derived Key Length
 * @description Detects Key Derivation Functions (KDFs) that produce keys shorter than 128 bits (16 bytes).
 * @assumption If key length is not specified (None/missing), the hash function's output length is used.
 *             Standard hash functions (SHA256/384/512) are considered to provide adequate length.
 * @kind problem
 * @id py/kdf-small-key-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// Identify KDF operations with insufficient derived key lengths
from KeyDerivationOperation keyDerivOp, string securityAlert, DataFlow::Node keyLengthParam
where
  // Locate the source of key size configuration
  keyLengthParam = keyDerivOp.getDerivedKeySizeSrc() and
  
  // Filter out cases using default hash length (None)
  not keyLengthParam.asExpr() instanceof None and
  
  // Check for insufficient key length cases
  (
    // Case 1: Key length explicitly set to less than 16 bytes
    exists(int derivedKeyBytes |
      derivedKeyBytes = keyLengthParam.asExpr().(IntegerLiteral).getValue() and
      derivedKeyBytes < 16 and
      securityAlert = "Insufficient derived key length. "
    )
    or
    // Case 2: Key length cannot be statically verified
    not keyLengthParam.asExpr() instanceof IntegerLiteral and
    securityAlert = "Derived key size is not statically verifiable. "
  )
select keyDerivOp, securityAlert + "Keys must be at least 16 bytes (128 bits). Configured key size: $@",
  keyLengthParam.asExpr(), keyLengthParam.asExpr().toString()