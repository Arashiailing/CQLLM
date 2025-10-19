/**
 * @name Insufficient KDF Derived Key Length
 * @description Detects Key Derivation Functions (KDF) that produce keys 
 *              shorter than 128 bits (16 bytes), which is cryptographically insecure.
 * @assumption When key length is not specified (None/missing), it defaults to the 
 *             underlying hash function's output length. Standard hash functions 
 *             (SHA256/384/512) are assumed to provide sufficient length.
 * @kind problem
 * @id py/kdf-small-key-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// Identify key derivation operations with inadequate key sizes
from KeyDerivationOperation keyDerivationOp, string warningMsg, DataFlow::Node keySizeParamSrc
where
  // Locate the key size configuration parameter
  keySizeParamSrc = keyDerivationOp.getDerivedKeySizeSrc() and
  
  // Filter out operations using default hash length (None values)
  not keySizeParamSrc.asExpr() instanceof None and
  (
    // Scenario 1: Explicitly configured with insufficient key length
    exists(int keyLengthVal |
      keyLengthVal = keySizeParamSrc.asExpr().(IntegerLiteral).getValue() and
      keyLengthVal < 16 and
      warningMsg = "Insufficient derived key length. "
    )
    or
    // Scenario 2: Key size cannot be statically determined
    not exists(keySizeParamSrc.asExpr().(IntegerLiteral).getValue()) and
    warningMsg = "Derived key size is not statically verifiable. "
  )
select keyDerivationOp, warningMsg + "Keys must be at least 16 bytes (128 bits). Configured key size: $@",
  keySizeParamSrc.asExpr(), keySizeParamSrc.asExpr().toString()