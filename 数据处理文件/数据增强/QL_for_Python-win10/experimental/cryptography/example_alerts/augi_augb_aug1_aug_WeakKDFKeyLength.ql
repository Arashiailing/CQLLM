/**
 * @name Insufficient KDF Derived Key Length
 * @description Identifies Key Derivation Functions (KDFs) generating keys shorter than 128 bits (16 bytes).
 * @assumption When key length is unspecified (None/missing), the hash function's output length is used.
 *             Standard hash functions (SHA256/384/512) are considered to provide sufficient length.
 * @kind problem
 * @id py/kdf-small-key-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// Detect KDF operations with inadequate derived key lengths
from KeyDerivationOperation kdfOperation, string alertMessage, DataFlow::Node keySizeSource
where
  // Identify the source of key size configuration
  keySizeSource = kdfOperation.getDerivedKeySizeSrc() and
  
  // Exclude cases using default hash length (None)
  not keySizeSource.asExpr() instanceof None and
  
  // Evaluate key length sufficiency
  (
    // Case 1: Explicitly configured key length below 16 bytes
    exists(int derivedKeyBytes |
      derivedKeyBytes = keySizeSource.asExpr().(IntegerLiteral).getValue() and
      derivedKeyBytes < 16 and
      alertMessage = "Insufficient derived key length. "
    )
    or
    // Case 2: Key length cannot be statically determined
    not keySizeSource.asExpr() instanceof IntegerLiteral and
    alertMessage = "Derived key size is not statically verifiable. "
  )
select kdfOperation, alertMessage + "Keys must be at least 16 bytes (128 bits). Configured key size: $@",
  keySizeSource.asExpr(), keySizeSource.asExpr().toString()