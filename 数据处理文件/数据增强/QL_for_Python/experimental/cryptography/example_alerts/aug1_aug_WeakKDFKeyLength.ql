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

// Detect KDF operations with insufficient key lengths
from KeyDerivationOperation kdfOp, string alertMsg, DataFlow::Node keySizeArg
where
  // Identify key size configuration source
  keySizeArg = kdfOp.getDerivedKeySizeSrc() and
  
  // Exclude cases using default hash length (None)
  not keySizeArg.asExpr() instanceof None and
  (
    // Case 1: Explicit integer literal < 16 bytes
    exists(int derivedKeyLength |
      derivedKeyLength = keySizeArg.asExpr().(IntegerLiteral).getValue() and
      derivedKeyLength < 16 and
      alertMsg = "Insufficient derived key length. "
    )
    or
    // Case 2: Non-statically verifiable key size
    not keySizeArg.asExpr() instanceof IntegerLiteral and
    alertMsg = "Derived key size is not statically verifiable. "
  )
select kdfOp, alertMsg + "Keys must be at least 16 bytes (128 bits). Configured key size: $@",
  keySizeArg.asExpr(), keySizeArg.asExpr().toString()