/**
 * @name Insufficient KDF Derived Key Length
 * @description Detects when a Key Derivation Function (KDF) produces keys shorter than 128 bits (16 bytes).
 * @assumption When key length is not explicitly specified (None or missing), the key length is assumed
 *             to be derived from the underlying hash function's output length. This query assumes
 *             that standard hash functions (SHA256, SHA384, SHA512) provide sufficient length.
 * @kind problem
 * @id py/kdf-small-key-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// Analyze key derivation operations to identify insufficient key sizes
from KeyDerivationOperation keyDerivationOp, string warningMessage, DataFlow::Node keySizeSource
where
  // Identify the source of the derived key size configuration
  keySizeSource = keyDerivationOp.getDerivedKeySizeSrc() and
  
  // Exclude cases where key size is None (relying on hash length)
  not keySizeSource.asExpr() instanceof None and
  (
    // Case 1: Key size is explicitly set as an integer literal less than 16 bytes
    exists(int keySize |
      keySize = keySizeSource.asExpr().(IntegerLiteral).getValue() and
      keySize < 16 and
      warningMessage = "Insufficient derived key length. "
    )
    or
    // Case 2: Key size cannot be statically verified
    not exists(keySizeSource.asExpr().(IntegerLiteral).getValue()) and
    warningMessage = "Derived key size is not statically verifiable. "
  )
select keyDerivationOp, warningMessage + "Keys must be at least 16 bytes (128 bits). Configured key size: $@",
  keySizeSource.asExpr(), keySizeSource.asExpr().toString()