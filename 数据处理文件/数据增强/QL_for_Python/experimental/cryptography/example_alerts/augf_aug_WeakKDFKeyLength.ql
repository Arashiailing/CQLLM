/**
 * @name Insufficient KDF Derived Key Length
 * @description Identifies Key Derivation Functions (KDFs) generating keys shorter than 128 bits (16 bytes).
 * @assumption When key length is unspecified (None/missing), it defaults to the underlying hash function's output length.
 *             This assumes standard hash functions (SHA256/SHA384/SHA512) provide sufficient length.
 * @kind problem
 * @id py/kdf-small-key-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// Analyze key derivation operations for insufficient key sizes
from KeyDerivationOperation kdfOperation, string alertMessage, DataFlow::Node keyLenConfig
where
  // Identify the source of key length configuration
  keyLenConfig = kdfOperation.getDerivedKeySizeSrc() and
  
  // Exclude cases relying on default hash length (None values)
  not keyLenConfig.asExpr() instanceof None and
  
  // Evaluate key length sufficiency
  (
    // Case 1: Explicitly configured key size is too small
    exists(int configuredLength |
      configuredLength = keyLenConfig.asExpr().(IntegerLiteral).getValue() and
      configuredLength < 16 and
      alertMessage = "Insufficient derived key length. "
    )
    or
    // Case 2: Key size cannot be statically determined
    not exists(keyLenConfig.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Derived key size is not statically verifiable. "
  )
select kdfOperation, alertMessage + "Keys must be at least 16 bytes (128 bits). Configured key size: $@",
  keyLenConfig.asExpr(), keyLenConfig.asExpr().toString()