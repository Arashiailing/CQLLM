/**
 * @name Insufficient KDF Derived Key Length
 * @description Identifies key derivation functions (KDF) producing keys shorter than 128 bits (16 bytes).
 * @assumption When key length is unspecified (e.g., None or omitted), 
 *             the length defaults to the underlying hash algorithm's output size.
 * @kind problem
 * @id py/kdf-small-key-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// Detect key derivation operations with inadequate key sizes
from KeyDerivationOperation kdfOp, string warningMsg, DataFlow::Node keySizeSpec
where
  // Obtain key size specification source, excluding None values
  keySizeSpec = kdfOp.getDerivedKeySizeSrc() and
  not keySizeSpec.asExpr() instanceof None and
  (
    // Case 1: Explicit integer value below minimum threshold
    exists(int keySizeValue | 
        keySizeValue = keySizeSpec.asExpr().(IntegerLiteral).getValue() and
        keySizeValue < 16 and
        warningMsg = "Derived key size is too small. "
    )
    or
    // Case 2: Non-integer key size specification (statically unverifiable)
    not exists(keySizeSpec.asExpr().(IntegerLiteral).getValue()) and
    warningMsg = "Derived key size is not a statically verifiable size. "
  )
select kdfOp, warningMsg + "Derived key size must be a minimum of 16 (bytes). Derived Key Size Config: $@",
  keySizeSpec.asExpr(), keySizeSpec.asExpr().toString()