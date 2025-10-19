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

// Identify KDF operations with inadequate key lengths
from KeyDerivationOperation kdfOperation, string alertMessage, DataFlow::Node keySizeSource
where
  // Retrieve key size configuration source
  keySizeSource = kdfOperation.getDerivedKeySizeSrc() and
  
  // Exclude default hash length cases (None)
  not keySizeSource.asExpr() instanceof None and
  (
    // Case 1: Explicit integer literal < 16 bytes
    exists(int derivedKeySize |
      derivedKeySize = keySizeSource.asExpr().(IntegerLiteral).getValue() and
      derivedKeySize < 16 and
      alertMessage = "Insufficient derived key length. "
    )
    or
    // Case 2: Non-statically verifiable key size
    not keySizeSource.asExpr() instanceof IntegerLiteral and
    alertMessage = "Derived key size is not statically verifiable. "
  )
select kdfOperation, alertMessage + "Keys must be at least 16 bytes (128 bits). Configured key size: $@",
  keySizeSource.asExpr(), keySizeSource.asExpr().toString()