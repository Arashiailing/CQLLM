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

// Identify KDF operations with insufficient key sizes
from KeyDerivationOperation kdfOperation, string alertMessage, DataFlow::Node keySizeParam
where
  // Retrieve key size configuration source
  keySizeParam = kdfOperation.getDerivedKeySizeSrc() and
  
  // Exclude cases where key size relies on hash function output (None)
  not keySizeParam.asExpr() instanceof None and
  (
    // Case 1: Explicit key size < 16 bytes (integer literal)
    exists(int derivedKeySize |
      derivedKeySize = keySizeParam.asExpr().(IntegerLiteral).getValue() and
      derivedKeySize < 16 and
      alertMessage = "Insufficient derived key length. "
    )
    or
    // Case 2: Key size cannot be statically verified (non-constant)
    not exists(keySizeParam.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Derived key size is not statically verifiable. "
  )
select kdfOperation, alertMessage + "Keys must be at least 16 bytes (128 bits). Configured key size: $@",
  keySizeParam.asExpr(), keySizeParam.asExpr().toString()