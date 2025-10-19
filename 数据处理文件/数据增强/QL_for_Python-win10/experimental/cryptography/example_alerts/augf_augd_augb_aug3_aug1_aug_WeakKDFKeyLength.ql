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
from KeyDerivationOperation kdfOp, string alertMsg, DataFlow::Node keySizeSrc
where
  // Get key size configuration source and exclude default hash length cases
  keySizeSrc = kdfOp.getDerivedKeySizeSrc() and
  not keySizeSrc.asExpr() instanceof None and
  
  // Handle two distinct vulnerability scenarios
  (
    // Scenario 1: Explicit key size specification below minimum threshold
    exists(int keySize |
      keySizeSrc.asExpr() instanceof IntegerLiteral and
      keySize = keySizeSrc.asExpr().(IntegerLiteral).getValue() and
      keySize < 16 and
      alertMsg = "Insufficient derived key length. "
    )
    or
    // Scenario 2: Non-statically verifiable key size configuration
    not keySizeSrc.asExpr() instanceof IntegerLiteral and
    alertMsg = "Derived key size is not statically verifiable. "
  )
select kdfOp, alertMsg + "Keys must be at least 16 bytes (128 bits). Configured key size: $@",
  keySizeSrc.asExpr(), keySizeSrc.asExpr().toString()