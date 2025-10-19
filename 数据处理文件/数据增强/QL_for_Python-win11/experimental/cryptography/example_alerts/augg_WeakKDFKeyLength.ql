/**
 * @name Small KDF derived key length.
 * @description KDF derived keys should be a minimum of 128 bits (16 bytes).
 * @assumption If the key length is not explicitly provided (e.g., it is None or otherwise not specified) assumes the length is derived from the hash length.
 * @kind problem
 * @id py/kdf-small-key-size
 * @problem.severity error
 * @precision high
 *
 * This query identifies Key Derivation Function (KDF) operations that produce derived keys
 * with insufficient length. It checks two scenarios:
 *   1. The derived key size is explicitly set to a value less than 16 bytes
 *   2. The derived key size cannot be statically verified (non-integer literal)
 * Note: When key size is None/unspecified, the query assumes sufficient length from hash algorithms
 * (e.g., SHA256/384/512) and relies on other queries to validate those cases.
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

from KeyDerivationOperation kdfOperation, string alertMessage, DataFlow::Node keySizeSource, Expr keySizeExpr
where
  // Retrieve the derived key size configuration source
  keySizeSource = kdfOperation.getDerivedKeySizeSrc() and
  keySizeExpr = keySizeSource.asExpr() and
  
  // Exclude cases where key size is None (assumed sufficient from hash algorithms)
  not keySizeExpr instanceof None and
  
  // Check for insufficient key size scenarios
  (
    // Case 1: Explicit integer value less than 16 bytes
    keySizeExpr instanceof IntegerLiteral and
    keySizeExpr.(IntegerLiteral).getValue() < 16 and
    alertMessage = "Derived key size is too small. "
    or
    // Case 2: Non-statically verifiable key size (not integer literal)
    not keySizeExpr instanceof IntegerLiteral and
    alertMessage = "Derived key size is not a statically verifiable size. "
  )
select kdfOperation, alertMessage + "Derived key size must be a minimum of 16 (bytes). Derived Key Size Config: $@",
  keySizeExpr, keySizeExpr.toString()