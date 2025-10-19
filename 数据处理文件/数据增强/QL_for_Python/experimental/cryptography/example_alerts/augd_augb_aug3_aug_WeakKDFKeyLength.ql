/**
 * @name Insufficient KDF Derived Key Length
 * @description Identifies Key Derivation Functions (KDF) that generate keys 
 *              shorter than 128 bits (16 bytes), which is cryptographically weak.
 * @assumption When key length is unspecified (None/missing), it defaults to the 
 *             underlying hash function's output length. Standard hash functions 
 *             (SHA256/384/512) are considered to provide adequate length.
 * @kind problem
 * @id py/kdf-small-key-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// Detect cryptographic key derivation operations with inadequate key lengths
from KeyDerivationOperation kdfOperation, string alertMessage, DataFlow::Node keySizeSource
where
  // Obtain the source of the key size parameter configuration
  keySizeSource = kdfOperation.getDerivedKeySizeSrc() and
  
  // Exclude operations that rely on default hash length (None values)
  not keySizeSource.asExpr() instanceof None and
  (
    // Case 1: Key length is explicitly set to an insufficient value
    exists(int derivedKeyLength |
      derivedKeyLength = keySizeSource.asExpr().(IntegerLiteral).getValue() and
      derivedKeyLength < 16 and
      alertMessage = "Insufficient derived key length. "
    )
    or
    // Case 2: Key length cannot be determined through static analysis
    not exists(keySizeSource.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Derived key size is not statically verifiable. "
  )
select kdfOperation, alertMessage + "Keys must be at least 16 bytes (128 bits). Configured key size: $@",
  keySizeSource.asExpr(), keySizeSource.asExpr().toString()