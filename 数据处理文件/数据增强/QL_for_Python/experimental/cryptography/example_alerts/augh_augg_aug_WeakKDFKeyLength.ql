/**
 * @name KDF Derived Key Length Insufficiency
 * @description Detects Key Derivation Functions (KDFs) that produce keys with length below 128 bits (16 bytes).
 * @assumption If key length is not specified (None/missing), the hash function's output length is utilized.
 *             Common hash functions (SHA256/384/512) are presumed to offer adequate length.
 * @kind problem
 * @id py/kdf-small-key-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// Examine key derivation operations for inadequate key lengths
from KeyDerivationOperation keyDerivationOp, string alertMsg, DataFlow::Node keyLengthNode
where
  // Identify the origin of the derived key length configuration
  keyLengthNode = keyDerivationOp.getDerivedKeySizeSrc() and
  
  // Exclude scenarios depending on hash function output (None/missing)
  not keyLengthNode.asExpr() instanceof None and
  (
    // Scenario 1: Explicit integer literal below 16 bytes
    exists(int derivedKeyLength |
      derivedKeyLength = keyLengthNode.asExpr().(IntegerLiteral).getValue() and
      derivedKeyLength < 16 and
      alertMsg = "Insufficient derived key length. "
    )
    or
    // Scenario 2: Non-statically verifiable key length
    not exists(keyLengthNode.asExpr().(IntegerLiteral).getValue()) and
    alertMsg = "Derived key size is not statically verifiable. "
  )
select keyDerivationOp, alertMsg + "Keys must be at least 16 bytes (128 bits). Configured key size: $@",
  keyLengthNode.asExpr(), keyLengthNode.asExpr().toString()