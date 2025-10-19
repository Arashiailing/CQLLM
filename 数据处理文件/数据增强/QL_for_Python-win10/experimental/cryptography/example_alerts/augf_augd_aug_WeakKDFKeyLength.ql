/**
 * @name Insufficient KDF Derived Key Length
 * @description Detects Key Derivation Functions (KDFs) generating keys shorter than 128 bits (16 bytes).
 * @assumption When key length is unspecified (None/missing), the hash function's output length is used.
 *             Standard hash functions (SHA256/384/512) are considered sufficient.
 * @kind problem
 * @id py/kdf-small-key-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// Analyze key derivation operations for insufficient key sizes
from KeyDerivationOperation keyDerivationOp, string warningMsg, DataFlow::Node keySizeSrc
where
  // Retrieve key length configuration source
  keySizeSrc = keyDerivationOp.getDerivedKeySizeSrc() and
  
  // Exclude cases using default hash length (None)
  not keySizeSrc.asExpr() instanceof None and
  (
    // Case 1: Explicitly configured key size < 16 bytes
    exists(int derivedKeySize |
      derivedKeySize = keySizeSrc.asExpr().(IntegerLiteral).getValue() and
      derivedKeySize < 16 and
      warningMsg = "Insufficient derived key length. "
    )
    or
    // Case 2: Non-statically verifiable key size
    not exists(keySizeSrc.asExpr().(IntegerLiteral).getValue()) and
    warningMsg = "Derived key size is not statically verifiable. "
  )
select keyDerivationOp, warningMsg + "Keys must be at least 16 bytes (128 bits). Configured key size: $@",
  keySizeSrc.asExpr(), keySizeSrc.asExpr().toString()