/**
 * @name Insufficient KDF Derived Key Length
 * @description Identifies Key Derivation Functions (KDFs) that produce keys with lengths less than 128 bits (16 bytes).
 * @assumption When key length is not specified (None/missing), the hash function's output length is utilized.
 *             Standard hash functions (SHA256/384/512) are presumed to provide adequate length.
 * @kind problem
 * @id py/kdf-small-key-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// Find KDF operations that generate keys with inadequate lengths
from KeyDerivationOperation kdfOperation, string alertMessage, DataFlow::Node keyLengthSource
where
  // Obtain the source of the key length configuration
  keyLengthSource = kdfOperation.getDerivedKeySizeSrc() and
  
  // Skip cases where key length defaults to hash output (None)
  not keyLengthSource.asExpr() instanceof None and
  (
    // Scenario 1: Key length explicitly set to an integer value less than 16 bytes
    exists(int keyLengthValue |
      keyLengthValue = keyLengthSource.asExpr().(IntegerLiteral).getValue() and
      keyLengthValue < 16 and
      alertMessage = "Insufficient derived key length detected. "
    )
    or
    // Scenario 2: Key length cannot be statically verified
    not keyLengthSource.asExpr() instanceof IntegerLiteral and
    alertMessage = "Derived key length cannot be statically verified. "
  )
select kdfOperation, alertMessage + "Minimum key length requirement is 16 bytes (128 bits). Current configuration: $@",
  keyLengthSource.asExpr(), keyLengthSource.asExpr().toString()