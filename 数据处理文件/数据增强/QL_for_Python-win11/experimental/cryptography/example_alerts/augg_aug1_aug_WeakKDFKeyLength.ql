/**
 * @name Insufficient KDF Derived Key Length
 * @description Detects Key Derivation Functions generating keys shorter than 128 bits (16 bytes).
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
from KeyDerivationOperation kdfOperation, string warningMessage, DataFlow::Node keySizeParameter
where
  // Locate key size configuration source
  keySizeParameter = kdfOperation.getDerivedKeySizeSrc() and
  
  // Exclude cases using default hash length (None)
  not keySizeParameter.asExpr() instanceof None and
  (
    // Case 1: Explicit integer literal under 16 bytes
    exists(int derivedKeyLength |
      derivedKeyLength = keySizeParameter.asExpr().(IntegerLiteral).getValue() and
      derivedKeyLength < 16 and
      warningMessage = "Insufficient derived key length. "
    )
    or
    // Case 2: Non-statically verifiable key size
    exists( | 
      not keySizeParameter.asExpr() instanceof IntegerLiteral and
      warningMessage = "Derived key size is not statically verifiable. "
    )
  )
select kdfOperation, warningMessage + "Keys must be at least 16 bytes (128 bits). Configured key size: $@",
  keySizeParameter.asExpr(), keySizeParameter.asExpr().toString()