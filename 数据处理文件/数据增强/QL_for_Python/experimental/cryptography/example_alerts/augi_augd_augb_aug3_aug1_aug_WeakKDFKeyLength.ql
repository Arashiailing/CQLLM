/**
 * @name Insufficient KDF Derived Key Length
 * @description Identifies Key Derivation Functions (KDFs) producing keys shorter than 128 bits (16 bytes).
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

// Detect KDF operations with inadequate key lengths
from KeyDerivationOperation kdfOp, string warningMsg, DataFlow::Node keySizeSrc
where
  // Obtain key size configuration source
  keySizeSrc = kdfOp.getDerivedKeySizeSrc() and
  
  // Exclude default hash length cases (None)
  not keySizeSrc.asExpr() instanceof None and
  (
    // Case 1: Explicit integer literal < 16 bytes
    exists(int keySize |
      keySize = keySizeSrc.asExpr().(IntegerLiteral).getValue() and
      keySize < 16 and
      warningMsg = "Insufficient derived key length. "
    )
    or
    // Case 2: Non-statically verifiable key size
    not keySizeSrc.asExpr() instanceof IntegerLiteral and
    warningMsg = "Derived key size is not statically verifiable. "
  )
select kdfOp, warningMsg + "Keys must be at least 16 bytes (128 bits). Configured key size: $@",
  keySizeSrc.asExpr(), keySizeSrc.asExpr().toString()