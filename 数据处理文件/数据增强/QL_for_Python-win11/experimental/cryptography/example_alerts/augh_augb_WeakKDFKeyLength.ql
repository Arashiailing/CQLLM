/**
 * @name Small KDF derived key length.
 * @description Detects key derivation functions (KDF) generating keys smaller than 128 bits (16 bytes).
 * @assumption When key length isn't explicitly specified (e.g., None or omitted), 
 *             the length is assumed to match the underlying hash algorithm's output length.
 * @kind problem
 * @id py/kdf-small-key-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// Identify key derivation operations with insufficient key sizes
from KeyDerivationOperation keyDerivationOp, string alertMessage, DataFlow::Node keySizeNode
where
  // Retrieve key size specification source, excluding None values
  keySizeNode = keyDerivationOp.getDerivedKeySizeSrc() and
  not keySizeNode.asExpr() instanceof None and
  (
    // Case 1: Explicitly defined integer value below minimum threshold
    exists(int keySizeValue | 
        keySizeValue = keySizeNode.asExpr().(IntegerLiteral).getValue() and
        keySizeValue < 16 and
        alertMessage = "Derived key size is too small. "
    )
    or
    // Case 2: Non-integer key size specification (statically unverifiable)
    not exists(keySizeNode.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Derived key size is not a statically verifiable size. "
  )
select keyDerivationOp, alertMessage + "Derived key size must be a minimum of 16 (bytes). Derived Key Size Config: $@",
  keySizeNode.asExpr(), keySizeNode.asExpr().toString()