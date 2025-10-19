/**
 * @name KDF Derived Key Length Insufficiency
 * @description Identifies Key Derivation Functions (KDFs) that generate keys with length below 128 bits (16 bytes).
 * @assumption When key length is not specified (None/missing), the hash function's output length is used.
 *             Common hash functions (SHA256/384/512) are assumed to provide sufficient length.
 * @kind problem
 * @id py/kdf-small-key-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// Analyze key derivation operations for insufficient key lengths
from KeyDerivationOperation kdfOperation, string warningMessage, DataFlow::Node keySizeSource
where
  // Identify the source of the derived key length configuration
  keySizeSource = kdfOperation.getDerivedKeySizeSrc() and
  
  // Exclude cases where key length depends on hash function output (None/missing)
  not keySizeSource.asExpr() instanceof None and
  (
    // Case 1: Explicit integer literal below 16 bytes
    exists(int derivedKeySize |
      derivedKeySize = keySizeSource.asExpr().(IntegerLiteral).getValue() and
      derivedKeySize < 16 and
      warningMessage = "Insufficient derived key length. "
    )
    or
    // Case 2: Non-statically verifiable key length
    not exists(keySizeSource.asExpr().(IntegerLiteral).getValue()) and
    warningMessage = "Derived key size is not statically verifiable. "
  )
select kdfOperation, warningMessage + "Keys must be at least 16 bytes (128 bits). Configured key size: $@",
  keySizeSource.asExpr(), keySizeSource.asExpr().toString()