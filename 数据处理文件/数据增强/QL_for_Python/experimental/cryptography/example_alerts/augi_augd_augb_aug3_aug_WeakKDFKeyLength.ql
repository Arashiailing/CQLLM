/**
 * @name Insufficient KDF Derived Key Length
 * @description Detects cryptographic weaknesses in Key Derivation Functions (KDF) 
 *              where the derived key length is less than 128 bits (16 bytes), 
 *              which is below minimum security standards.
 * @assumption When key length is unspecified (None/missing), it defaults to the 
 *             output length of the underlying hash function. Standard hash functions 
 *             (SHA256/384/512) are assumed to provide adequate key length.
 * @kind problem
 * @id py/kdf-small-key-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// Identify cryptographic key derivation operations with inadequate key lengths
from KeyDerivationOperation cryptoOperation, string securityAlert, DataFlow::Node keyLengthConfig
where
  // Extract the configuration source for the derived key size parameter
  keyLengthConfig = cryptoOperation.getDerivedKeySizeSrc() and
  
  // Filter out operations that use default hash length (None values)
  not keyLengthConfig.asExpr() instanceof None and
  (
    // Scenario 1: Key length is explicitly configured to an insufficient value
    exists(int computedKeyLength |
      computedKeyLength = keyLengthConfig.asExpr().(IntegerLiteral).getValue() and
      computedKeyLength < 16 and
      securityAlert = "Cryptographic weakness: Insufficient derived key length. "
    )
    or
    // Scenario 2: Key length cannot be statically determined
    not exists(keyLengthConfig.asExpr().(IntegerLiteral).getValue()) and
    securityAlert = "Security concern: Derived key size is not statically verifiable. "
  )
select cryptoOperation, securityAlert + "Keys must be at least 16 bytes (128 bits). Configured key size: $@",
  keyLengthConfig.asExpr(), keyLengthConfig.asExpr().toString()