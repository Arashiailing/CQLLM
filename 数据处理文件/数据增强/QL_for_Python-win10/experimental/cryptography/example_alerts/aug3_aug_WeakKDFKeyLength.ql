/**
 * @name Insufficient KDF Derived Key Length
 * @description Identifies Key Derivation Functions (KDF) that generate keys 
 *              shorter than 128 bits (16 bytes), which is cryptographically weak.
 * @assumption When key length is unspecified (None/missing), it defaults to the 
 *             underlying hash function's output length. Standard hash functions 
 *             (SHA256/384/512) are assumed to provide sufficient length.
 * @kind problem
 * @id py/kdf-small-key-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// Analyze key derivation operations for insufficient key sizes
from KeyDerivationOperation kdfOperation, string alertMessage, DataFlow::Node keySizeConfigSource
where
  // Identify the source of key size configuration
  keySizeConfigSource = kdfOperation.getDerivedKeySizeSrc() and
  
  // Exclude cases relying on default hash length (None values)
  not keySizeConfigSource.asExpr() instanceof None and
  (
    // Case 1: Explicit small integer configuration (<16 bytes)
    exists(int configuredSize |
      configuredSize = keySizeConfigSource.asExpr().(IntegerLiteral).getValue() and
      configuredSize < 16 and
      alertMessage = "Insufficient derived key length. "
    )
    or
    // Case 2: Non-statically verifiable key size
    not exists(keySizeConfigSource.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Derived key size is not statically verifiable. "
  )
select kdfOperation, alertMessage + "Keys must be at least 16 bytes (128 bits). Configured key size: $@",
  keySizeConfigSource.asExpr(), keySizeConfigSource.asExpr().toString()