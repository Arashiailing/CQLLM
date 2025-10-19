/**
 * @name Insufficient KDF Derived Key Length
 * @description Detects Key Derivation Functions (KDF) producing keys 
 *              shorter than 128 bits (16 bytes), which is cryptographically insecure.
 * @assumption When key length is unspecified (None/missing), it defaults to the 
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

// Analyze key derivation operations for insufficient key sizes
from KeyDerivationOperation kdfOp, string warningMessage, DataFlow::Node keySizeSource
where
  // Identify the source of key size configuration
  keySizeSource = kdfOp.getDerivedKeySizeSrc() and
  
  // Exclude cases relying on default hash length (None values)
  not keySizeSource.asExpr() instanceof None and
  (
    // Case 1: Explicit small integer configuration (<16 bytes)
    exists(int keySizeValue |
      keySizeValue = keySizeSource.asExpr().(IntegerLiteral).getValue() and
      keySizeValue < 16 and
      warningMessage = "Insufficient derived key length. "
    )
    or
    // Case 2: Non-statically verifiable key size
    not exists(keySizeSource.asExpr().(IntegerLiteral).getValue()) and
    warningMessage = "Derived key size is not statically verifiable. "
  )
select kdfOp, warningMessage + "Keys must be at least 16 bytes (128 bits). Configured key size: $@",
  keySizeSource.asExpr(), keySizeSource.asExpr().toString()