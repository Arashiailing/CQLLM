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

// Identify Key Derivation Function operations with insufficient key sizes
from KeyDerivationOperation kdfOp, string diagnosticMsg, DataFlow::Node keySizeSource
where
  // Retrieve the source of derived key size configuration
  keySizeSource = kdfOp.getDerivedKeySizeSrc() and
  // Exclude cases where key size is explicitly set to None (handled by hash-length assumption)
  not keySizeSource.asExpr() instanceof None and
  (
    // Case 1: Explicit integer literal value below 16 bytes
    keySizeSource.asExpr() instanceof IntegerLiteral and
    keySizeSource.asExpr().(IntegerLiteral).getValue() < 16 and
    diagnosticMsg = "Derived key size is too small. "
    or
    // Case 2: Non-integer key size (cannot statically verify minimum length)
    not keySizeSource.asExpr() instanceof IntegerLiteral and
    diagnosticMsg = "Derived key size is not a statically verifiable size. "
  )
select kdfOp, diagnosticMsg + "Derived key size must be a minimum of 16 (bytes). Derived Key Size Config: $@",
  keySizeSource.asExpr(), keySizeSource.asExpr().toString()