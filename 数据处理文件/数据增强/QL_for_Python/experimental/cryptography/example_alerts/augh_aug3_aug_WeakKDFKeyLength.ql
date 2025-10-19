/**
 * @name Insufficient KDF Derived Key Length
 * @description Detects Key Derivation Functions (KDFs) that produce keys 
 *              shorter than 128 bits (16 bytes), which is cryptographically insecure.
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

// Identify key derivation operations with insufficient key sizes
from KeyDerivationOperation keyDerivationOp, string warningMessage, DataFlow::Node keySizeSource
where
  // Obtain the source node that configures the derived key size
  keySizeSource = keyDerivationOp.getDerivedKeySizeSrc() and
  
  // Filter out cases that rely on default hash length (None values)
  not keySizeSource.asExpr() instanceof None and
  (
    // Check for explicitly configured small key sizes (<16 bytes)
    exists(int explicitKeySize |
      explicitKeySize = keySizeSource.asExpr().(IntegerLiteral).getValue() and
      explicitKeySize < 16 and
      warningMessage = "Insufficient derived key length. "
    )
    or
    // Check for non-statically verifiable key sizes
    not exists(keySizeSource.asExpr().(IntegerLiteral).getValue()) and
    warningMessage = "Derived key size is not statically verifiable. "
  )
select keyDerivationOp, warningMessage + "Keys must be at least 16 bytes (128 bits). Configured key size: $@",
  keySizeSource.asExpr(), keySizeSource.asExpr().toString()