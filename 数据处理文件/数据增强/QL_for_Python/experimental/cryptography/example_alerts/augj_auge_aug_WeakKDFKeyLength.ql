/**
 * @name Insufficient KDF Derived Key Length
 * @description Detects Key Derivation Functions (KDFs) generating keys shorter than 128 bits (16 bytes).
 * @assumption When key length is unspecified (None/missing), the hash function's output length is used.
 *             Standard hash functions (SHA256/384/512) are assumed to provide sufficient length.
 * @kind problem
 * @id py/kdf-small-key-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// Identify KDF operations with insufficient key sizes
from KeyDerivationOperation kdfOp, string warningMsg, DataFlow::Node keySizeNode
where
  // Get key size configuration source
  keySizeNode = kdfOp.getDerivedKeySizeSrc() and
  
  // Exclude cases where key size relies on hash function output (None)
  not keySizeNode.asExpr() instanceof None and
  (
    // Case 1: Explicit key size < 16 bytes (integer literal)
    exists(int keySizeValue |
      keySizeValue = keySizeNode.asExpr().(IntegerLiteral).getValue() and
      keySizeValue < 16 and
      warningMsg = "Insufficient derived key length. "
    )
    or
    // Case 2: Key size cannot be statically verified (non-constant)
    not exists(keySizeNode.asExpr().(IntegerLiteral).getValue()) and
    warningMsg = "Derived key size is not statically verifiable. "
  )
select kdfOp, warningMsg + "Keys must be at least 16 bytes (128 bits). Configured key size: $@",
  keySizeNode.asExpr(), keySizeNode.asExpr().toString()