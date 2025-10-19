/**
 * @name Insufficient KDF Derived Key Length
 * @description Identifies Key Derivation Functions (KDFs) generating keys shorter than 128 bits (16 bytes).
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

// Analyze key derivation operations for insufficient key sizes
from KeyDerivationOperation kdfOp, string msg, DataFlow::Node keySizeNode
where
  // Identify the source of derived key size configuration
  keySizeNode = kdfOp.getDerivedKeySizeSrc() and
  
  // Exclude cases relying on hash function output (None/missing)
  not keySizeNode.asExpr() instanceof None and
  (
    // Case 1: Explicit integer literal < 16 bytes
    exists(int keySize |
      keySize = keySizeNode.asExpr().(IntegerLiteral).getValue() and
      keySize < 16 and
      msg = "Insufficient derived key length. "
    )
    or
    // Case 2: Non-statically verifiable key size
    not exists(keySizeNode.asExpr().(IntegerLiteral).getValue()) and
    msg = "Derived key size is not statically verifiable. "
  )
select kdfOp, msg + "Keys must be at least 16 bytes (128 bits). Configured key size: $@",
  keySizeNode.asExpr(), keySizeNode.asExpr().toString()