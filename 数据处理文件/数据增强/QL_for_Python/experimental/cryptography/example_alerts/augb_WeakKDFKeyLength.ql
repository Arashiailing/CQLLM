/**
 * @name Small KDF derived key length.
 * @description KDF derived keys should be a minimum of 128 bits (16 bytes).
 * @assumption If the key length is not explicitly provided (e.g., it is None or otherwise not specified) assumes the length is derived from the hash length.
 * @kind problem
 * @id py/kdf-small-key-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// Analyze key derivation operations to identify insufficient key sizes
from KeyDerivationOperation kdfOp, string message, DataFlow::Node keySizeSource
where
  // Obtain the key size specification source and exclude None values
  keySizeSource = kdfOp.getDerivedKeySizeSrc() and
  not keySizeSource.asExpr() instanceof None and
  (
    // Case 1: Explicitly specified integer value that's too small
    exists(int derivedSize | 
        derivedSize = keySizeSource.asExpr().(IntegerLiteral).getValue() and
        derivedSize < 16 and
        message = "Derived key size is too small. "
    )
    or
    // Case 2: Non-integer key size specification (statically unverifiable)
    not exists(keySizeSource.asExpr().(IntegerLiteral).getValue()) and
    message = "Derived key size is not a statically verifiable size. "
  )
select kdfOp, message + "Derived key size must be a minimum of 16 (bytes). Derived Key Size Config: $@",
  keySizeSource.asExpr(), keySizeSource.asExpr().toString()