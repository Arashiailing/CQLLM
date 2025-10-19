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

// Analyze key derivation operations for insufficient key sizes
from KeyDerivationOperation kdfOperation, string alertMessage, DataFlow::Node keyLengthSource
where
  // Obtain key length configuration source
  keyLengthSource = kdfOperation.getDerivedKeySizeSrc() and
  
  // Exclude cases relying on default hash length (None)
  not keyLengthSource.asExpr() instanceof None and
  (
    // Case 1: Explicitly configured key size < 16 bytes
    exists(int configuredKeySize |
      configuredKeySize = keyLengthSource.asExpr().(IntegerLiteral).getValue() and
      configuredKeySize < 16 and
      alertMessage = "Insufficient derived key length. "
    )
    or
    // Case 2: Non-statically verifiable key size
    not exists(keyLengthSource.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Derived key size is not statically verifiable. "
  )
select kdfOperation, alertMessage + "Keys must be at least 16 bytes (128 bits). Configured key size: $@",
  keyLengthSource.asExpr(), keyLengthSource.asExpr().toString()